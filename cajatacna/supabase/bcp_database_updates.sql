-- ====================================================================
-- SCRIPT DE ACTUALIZACIÓN DE BASE DE DATOS (NUEVAS TABLAS Y ASESORES)
-- Copia y pega esto en el SQL Editor de tu proyecto de Supabase.
-- ====================================================================

begin;

-- 1. Agregar campo es_asesor a la tabla de perfiles (si no existe)
alter table public.perfiles 
add column if not exists es_asesor boolean not null default false;

-- 2. Crear tabla solicitudes_prestamo
create table if not exists public.solicitudes_prestamo (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users(id) on delete cascade,
  monto_solicitado  numeric(14,2) not null check (monto_solicitado > 0),
  cuotas            integer not null check (cuotas > 0),
  tasa_interes      numeric(7,4) not null default 0 check (tasa_interes >= 0),
  motivo            text not null,
  estado            text not null default 'pendiente' check (estado in ('pendiente','aprobado','rechazado')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- 3. Crear índices para optimizar consultas
create index if not exists solicitudes_prestamo_user_id_idx on public.solicitudes_prestamo(user_id);
create index if not exists solicitudes_prestamo_estado_idx on public.solicitudes_prestamo(estado);

-- 4. Trigger de updated_at para solicitudes_prestamo
drop trigger if exists solicitudes_prestamo_set_updated_at on public.solicitudes_prestamo;
create trigger solicitudes_prestamo_set_updated_at
  before update on public.solicitudes_prestamo
  for each row execute function public.set_updated_at();

-- 5. Habilitar RLS en solicitudes_prestamo
alter table public.solicitudes_prestamo enable row level security;

-- 6. Políticas RLS para solicitudes_prestamo
drop policy if exists "solicitudes_select" on public.solicitudes_prestamo;
create policy "solicitudes_select" on public.solicitudes_prestamo
  for select to authenticated using (
    user_id = auth.uid() or 
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

drop policy if exists "solicitudes_insert" on public.solicitudes_prestamo;
create policy "solicitudes_insert" on public.solicitudes_prestamo
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "solicitudes_update" on public.solicitudes_prestamo;
create policy "solicitudes_update" on public.solicitudes_prestamo
  for update to authenticated using (
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  ) with check (
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

-- 7. Actualizar políticas RLS de otras tablas para permitir acceso a asesores

-- Perfiles (para que el asesor vea nombres y documentos de los solicitantes)
drop policy if exists "perfiles_select_asesor" on public.perfiles;
create policy "perfiles_select_asesor" on public.perfiles
  for select to authenticated using (
    user_id = auth.uid() or 
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

-- Cuentas (para que el asesor evalúe saldos y realice el desembolso)
drop policy if exists "cuentas_select_asesor" on public.cuentas;
create policy "cuentas_select_asesor" on public.cuentas
  for select to authenticated using (
    user_id = auth.uid() or 
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

drop policy if exists "cuentas_update_asesor" on public.cuentas;
create policy "cuentas_update_asesor" on public.cuentas
  for update to authenticated using (
    user_id = auth.uid() or 
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  ) with check (
    user_id = auth.uid() or 
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

-- Transacciones (para registrar el desembolso de préstamo)
drop policy if exists "transacciones_insert_asesor" on public.transacciones;
create policy "transacciones_insert_asesor" on public.transacciones
  for insert to authenticated with check (
    (select 1 from public.cuentas c where c.id = transacciones.cuenta_id and c.user_id = auth.uid()) is not null or
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

drop policy if exists "transacciones_select_asesor" on public.transacciones;
create policy "transacciones_select_asesor" on public.transacciones
  for select to authenticated using (
    exists (select 1 from public.cuentas c where c.id = transacciones.cuenta_id and c.user_id = auth.uid()) or
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

-- Préstamos (para registrar el nuevo préstamo aprobado)
drop policy if exists "prestamos_insert_asesor" on public.prestamos;
create policy "prestamos_insert_asesor" on public.prestamos
  for insert to authenticated with check (
    user_id = auth.uid() or 
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

drop policy if exists "prestamos_select_asesor" on public.prestamos;
create policy "prestamos_select_asesor" on public.prestamos
  for select to authenticated using (
    user_id = auth.uid() or 
    (select es_asesor from public.perfiles where user_id = auth.uid() limit 1) = true
  );

-- 8. Crear y sembrar el usuario ASESOR DEMO en auth.users y public.perfiles
do $$
declare
  v_asesor_id uuid := gen_random_uuid();
  v_hashed_password text;
begin
  -- Clave: 123456 (encriptada con bcrypt)
  v_hashed_password := extensions.crypt('123456', extensions.gen_salt('bf'));

  -- Eliminar si ya existe para re-ejecución limpia
  delete from auth.users where email = 'asesor@cajatacna.com';
  
  insert into auth.users (
    id, instance_id, aud, role,
    email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, confirmation_token, recovery_token,
    email_change_token_new, email_change
  ) values (
    v_asesor_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'asesor@cajatacna.com', v_hashed_password,
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"nombre":"Asesor CAJATACNA"}',
    false, '', '', '', ''
  );

  insert into public.perfiles (
    user_id, nombre_completo, email,
    tipo_documento, numero_documento,
    tarjeta_ultimos4, telefono, direccion
  ) values (
    v_asesor_id, 'Asesor Principal CAJATACNA', 'asesor@cajatacna.com',
    'DNI', '00000001',
    '0000', '999999999', 'Sede Central CAJATACNA, Miraflores, Lima'
  );

  -- Forzar la bandera de asesor a true
  update public.perfiles set es_asesor = true where user_id = v_asesor_id;
end;
$$;

commit;
