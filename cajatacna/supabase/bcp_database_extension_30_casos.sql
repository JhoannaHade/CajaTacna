-- ====================================================================
-- SCRIPT DE EXTENSIÓN PARA 30 CASOS DE ORIGINACIÓN CRÉDITO EMPRESARIAL
-- Copia y pega esto en el SQL Editor de tu proyecto de Supabase.
-- ====================================================================

begin;

-- 1. Modificar tabla solicitudes_prestamo para agregar columnas de originación empresarial
alter table public.solicitudes_prestamo add column if not exists numero_expediente text;
alter table public.solicitudes_prestamo add column if not exists canal text default 'cliente';
alter table public.solicitudes_prestamo add column if not exists garantia text;
alter table public.solicitudes_prestamo add column if not exists seguro_desgravamen boolean default true;
alter table public.solicitudes_prestamo add column if not exists monto_aprobado numeric(14,2);
alter table public.solicitudes_prestamo add column if not exists motivo_rechazo text;
alter table public.solicitudes_prestamo add column if not exists condicion_adicional text;
alter table public.solicitudes_prestamo add column if not exists firma_cliente_base64 text;
alter table public.solicitudes_prestamo add column if not exists lat_captura numeric(10,7);
alter table public.solicitudes_prestamo add column if not exists lng_captura numeric(10,7);

-- 2. Modificar constraint de estado en solicitudes_prestamo
alter table public.solicitudes_prestamo drop constraint if exists solicitudes_prestamo_estado_check;
alter table public.solicitudes_prestamo add constraint solicitudes_prestamo_estado_check 
  check (estado in ('borrador', 'enviado', 'recibido_comite', 'en_evaluacion', 'aprobado', 'condicionado', 'rechazado', 'desembolsado', 'pendiente'));

-- 3. Crear tabla solicitudes_documentos para almacenar fotos/sustentos
create table if not exists public.solicitudes_documentos (
  id              uuid primary key default gen_random_uuid(),
  solicitud_id    uuid not null references public.solicitudes_prestamo(id) on delete cascade,
  tipo_documento  text not null, -- 'dni_anverso', 'dni_reverso', 'sustento_ingresos', 'foto_negocio', 'foto_visita'
  storage_url     text,
  created_at      timestamptz not null default now()
);

-- 4. Modificar tabla cronograma_pagos para incluir campos de amortización detallada
alter table public.cronograma_pagos add column if not exists nro_cuota integer;
alter table public.cronograma_pagos add column if not exists monto_capital numeric(14,2);
alter table public.cronograma_pagos add column if not exists monto_interes numeric(14,2);
alter table public.cronograma_pagos add column if not exists saldo numeric(14,2);

-- 5. Habilitar RLS en solicitudes_documentos
alter table public.solicitudes_documentos enable row level security;

-- 6. Políticas RLS para solicitudes_documentos
drop policy if exists "documentos_select" on public.solicitudes_documentos;
create policy "documentos_select" on public.solicitudes_documentos
  for select to authenticated using (
    exists (
      select 1 from public.solicitudes_prestamo s 
      where s.id = solicitudes_documentos.solicitud_id 
      and (s.user_id = auth.uid() or public.check_es_asesor(auth.uid()) = true)
    )
  );

drop policy if exists "documentos_insert" on public.solicitudes_documentos;
create policy "documentos_insert" on public.solicitudes_documentos
  for insert to authenticated with check (
    exists (
      select 1 from public.solicitudes_prestamo s 
      where s.id = solicitudes_documentos.solicitud_id 
      and (s.user_id = auth.uid() or public.check_es_asesor(auth.uid()) = true)
    )
  );

-- 7. Trigger para encolar automáticamente solicitudes en la cartera_diaria del asesor
create or replace function public.auto_assign_solicitud_to_cartera()
returns trigger language plpgsql security definer as $$
declare
  v_asesor_id uuid;
begin
  -- Solo se activa cuando pasa a estado 'enviado'
  if (new.estado = 'enviado') then
    -- Obtener el ID del asesor demo
    select user_id into v_asesor_id from public.perfiles where email = 'asesor@cajatacna.com' limit 1;
    if v_asesor_id is not null then
      new.asesor_id := v_asesor_id;
      -- Insertar en cartera_diaria si no está asignado hoy
      if not exists (
        select 1 from public.cartera_diaria 
        where asesor_id = v_asesor_id and cliente_id = new.user_id and fecha_asignacion = current_date
      ) then
        insert into public.cartera_diaria (
          asesor_id,
          cliente_id,
          fecha_asignacion,
          tipo_gestion,
          prioridad,
          score_prioridad,
          estado_visita,
          monto_credito
        ) values (
          v_asesor_id,
          new.user_id,
          current_date,
          'NUEVA_SOLICITUD',
          'Media',
          85,
          'pendiente',
          new.monto_solicitado
        );
      end if;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists tr_auto_assign_solicitud on public.solicitudes_prestamo;
create trigger tr_auto_assign_solicitud
  before insert or update on public.solicitudes_prestamo
  for each row execute function public.auto_assign_solicitud_to_cartera();

commit;
