-- ====================================================================
-- SCRIPT DE CORRECCIÓN DE RECURSIÓN INFINITA EN RLS
-- Copia y pega esto en el SQL Editor de tu proyecto de Supabase.
-- ====================================================================

begin;

-- 1. Crear función de seguridad para evitar recursión infinita en las políticas RLS
create or replace function public.check_es_asesor(p_user_id uuid)
returns boolean language plpgsql security definer set search_path = public as $$
declare
  v_es_asesor boolean;
begin
  select es_asesor into v_es_asesor
  from public.perfiles
  where user_id = p_user_id
  limit 1;
  
  return coalesce(v_es_asesor, false);
end;
$$;

grant execute on function public.check_es_asesor(uuid) to anon, authenticated;


-- 2. Corregir políticas de Perfiles
drop policy if exists "perfiles_select" on public.perfiles;
create policy "perfiles_select" on public.perfiles
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "perfiles_select_asesor" on public.perfiles;


-- 3. Corregir políticas de Cuentas
drop policy if exists "cuentas_select" on public.cuentas;
create policy "cuentas_select" on public.cuentas
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "cuentas_update" on public.cuentas;
create policy "cuentas_update" on public.cuentas
  for update to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  ) with check (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "cuentas_select_asesor" on public.cuentas;
drop policy if exists "cuentas_update_asesor" on public.cuentas;


-- 4. Corregir políticas de Transacciones
drop policy if exists "transacciones_select" on public.transacciones;
create policy "transacciones_select" on public.transacciones
  for select to authenticated using (
    exists (select 1 from public.cuentas c where c.id = transacciones.cuenta_id and c.user_id = auth.uid()) or
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "transacciones_insert" on public.transacciones;
create policy "transacciones_insert" on public.transacciones
  for insert to authenticated with check (
    exists (select 1 from public.cuentas c where c.id = transacciones.cuenta_id and c.user_id = auth.uid()) or
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "transacciones_select_asesor" on public.transacciones;
drop policy if exists "transacciones_insert_asesor" on public.transacciones;


-- 5. Corregir políticas de Préstamos
drop policy if exists "prestamos_select" on public.prestamos;
create policy "prestamos_select" on public.prestamos
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "prestamos_insert" on public.prestamos;
create policy "prestamos_insert" on public.prestamos
  for insert to authenticated with check (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "prestamos_select_asesor" on public.prestamos;
drop policy if exists "prestamos_insert_asesor" on public.prestamos;


-- 6. Corregir políticas de Solicitudes de Préstamo
drop policy if exists "solicitudes_select" on public.solicitudes_prestamo;
create policy "solicitudes_select" on public.solicitudes_prestamo
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

drop policy if exists "solicitudes_update" on public.solicitudes_prestamo;
create policy "solicitudes_update" on public.solicitudes_prestamo
  for update to authenticated using (
    public.check_es_asesor(auth.uid()) = true
  ) with check (
    public.check_es_asesor(auth.uid()) = true
  );

-- 7. Agregar columnas de seguimiento de asesor si no existen
alter table public.solicitudes_prestamo add column if not exists asesor_id uuid references auth.users(id);
alter table public.prestamos add column if not exists asesor_id uuid references auth.users(id);

-- 8. Crear triggers para automatizar el registro de asesor_id
create or replace function public.set_solicitud_asesor_id()
returns trigger language plpgsql security definer as $$
begin
  if (new.estado in ('aprobado', 'rechazado')) and (new.asesor_id is null) then
    if public.check_es_asesor(auth.uid()) = true then
      new.asesor_id := auth.uid();
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists tr_set_solicitud_asesor_id on public.solicitudes_prestamo;
create trigger tr_set_solicitud_asesor_id
  before update on public.solicitudes_prestamo
  for each row execute function public.set_solicitud_asesor_id();

create or replace function public.set_prestamo_asesor_id()
returns trigger language plpgsql security definer as $$
begin
  if (new.asesor_id is null) then
    if public.check_es_asesor(auth.uid()) = true then
      new.asesor_id := auth.uid();
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists tr_set_prestamo_asesor_id on public.prestamos;
create trigger tr_set_prestamo_asesor_id
  before insert on public.prestamos
  for each row execute function public.set_prestamo_asesor_id();

commit;
