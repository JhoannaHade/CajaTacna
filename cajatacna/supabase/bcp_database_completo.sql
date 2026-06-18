-- =============================================================
-- CAJATACNA Demo Database Completo (Con Asesores y Préstamos) — Supabase SQL Editor
-- =============================================================
-- INSTRUCCIONES:
--   1. Copia y pega ESTE ARCHIVO COMPLETO en el SQL Editor de Supabase.
--   2. Haz clic en "Run".
--   3. Listo — se crean las tablas, políticas, funciones, triggers
--      Y los 3 usuarios de prueba + 1 asesor demo con sus contraseñas.
--
-- CREDENCIALES DE PRUEBA (creadas automáticamente):
--   Clientes (clave: 123456):
--     user1@cajatacna.com
--     user2@cajatacna.com
--     user3@cajatacna.com
--   Asesor (clave: 123456):
--     asesor@cajatacna.com
-- =============================================================

begin;

-- ----------------------------------------------------------
-- 0. Limpiar funciones y tablas existentes
-- ----------------------------------------------------------
do $$
declare
  routine record;
begin
  for routine in
    select p.oid::regprocedure as identity
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
  loop
    execute format('drop function if exists %s cascade', routine.identity);
  end loop;
end;
$$;

drop table if exists public.cronograma_pagos   cascade;
drop table if exists public.movimientos_ahorro cascade;
drop table if exists public.transacciones      cascade;
drop table if exists public.pagos_servicios    cascade;
drop table if exists public.transferencias     cascade;
drop table if exists public.pagos              cascade;
drop table if exists public.cuentas_ahorro     cascade;
drop table if exists public.creditos           cascade;
drop table if exists public.cuentas            cascade;
drop table if exists public.prestamos          cascade;
drop table if exists public.solicitudes_prestamo cascade;
drop table if exists public.tarjetas           cascade;
drop table if exists public.perfiles           cascade;

-- Habilitar extensión de criptografía (necesaria para bcrypt)
create extension if not exists pgcrypto with schema extensions;

-- ----------------------------------------------------------
-- 1. Función utilitaria para updated_at automático
-- ----------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = public as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ----------------------------------------------------------
-- 2. Tablas principales
-- ----------------------------------------------------------
create table public.perfiles (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null unique,
  nombre_completo  text not null,
  email            text not null default '',
  tipo_documento   text not null default 'DNI',
  numero_documento text not null default '',
  tarjeta_ultimos4 text not null default '',
  telefono         text not null default '',
  direccion        text not null default '',
  es_asesor        boolean not null default false,
  fecha_registro   timestamptz not null default now(),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table public.cuentas (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null,
  tipo         text not null,
  numero_cuenta text not null unique,
  saldo        numeric(14,2) not null default 0 check (saldo >= 0),
  moneda       text not null default 'PEN',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table public.transacciones (
  id          uuid primary key default gen_random_uuid(),
  cuenta_id   uuid not null references public.cuentas(id) on delete cascade,
  tipo        text not null check (tipo in ('debito','credito')),
  monto       numeric(14,2) not null check (monto > 0),
  descripcion text not null,
  fecha       timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

create table public.cuentas_ahorro (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null,
  numero_cuenta text not null unique,
  saldo        numeric(14,2) not null default 0 check (saldo >= 0),
  moneda       text not null default 'PEN',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table public.movimientos_ahorro (
  id          uuid primary key default gen_random_uuid(),
  cuenta_id   uuid not null references public.cuentas_ahorro(id) on delete cascade,
  tipo        text not null check (tipo in ('deposito','retiro','interes')),
  monto       numeric(14,2) not null check (monto > 0),
  descripcion text not null,
  fecha       timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

create table public.creditos (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null,
  monto           numeric(14,2) not null check (monto > 0),
  saldo_restante  numeric(14,2) not null check (saldo_restante >= 0),
  cuotas          integer not null check (cuotas > 0),
  cuotas_pagadas  integer not null default 0 check (cuotas_pagadas >= 0),
  tasa_interes    numeric(7,4) not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (cuotas_pagadas <= cuotas)
);

create table public.cronograma_pagos (
  id                uuid primary key default gen_random_uuid(),
  credito_id        uuid not null references public.creditos(id) on delete cascade,
  fecha_vencimiento date not null,
  monto_cuota       numeric(14,2) not null check (monto_cuota > 0),
  estado            text not null default 'pendiente' check (estado in ('pendiente','pagado','vencido')),
  created_at        timestamptz not null default now()
);

create table public.transferencias (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid(),
  cuenta_destino text not null,
  monto          numeric(14,2) not null check (monto > 0),
  descripcion    text not null,
  fecha          timestamptz not null default now(),
  estado         text not null default 'procesado',
  created_at     timestamptz not null default now()
);

create table public.pagos_servicios (
  id        uuid primary key default gen_random_uuid(),
  user_id   uuid not null default auth.uid(),
  servicio  text not null,
  contrato  text not null,
  monto     numeric(14,2) not null check (monto > 0),
  estado    text not null default 'procesado',
  fecha     timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.pagos (
  id        uuid primary key default gen_random_uuid(),
  user_id   uuid not null,
  servicio  text not null,
  monto     numeric(14,2) not null check (monto > 0),
  fecha     timestamptz not null default now(),
  estado    text not null default 'procesado',
  created_at timestamptz not null default now()
);

create table public.tarjetas (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null,
  numero           text not null,
  tipo             text not null,
  marca            text not null,
  fecha_vencimiento text not null,
  created_at       timestamptz not null default now()
);

create table public.prestamos (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null,
  asesor_id         uuid references auth.users(id),
  tipo              text not null,
  numero_enmascarado text not null,
  capital_total     numeric(14,2) not null check (capital_total > 0),
  capital_pendiente numeric(14,2) not null check (capital_pendiente >= 0),
  cuota_numero      integer not null check (cuota_numero > 0),
  cuotas_total      integer not null check (cuotas_total > 0),
  fecha_limite      date not null,
  capital_cuota     numeric(14,2) not null default 0,
  intereses_cuota   numeric(14,2) not null default 0,
  seguros_cuota     numeric(14,2) not null default 0,
  created_at        timestamptz not null default now(),
  check (cuota_numero <= cuotas_total)
);

create table public.solicitudes_prestamo (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users(id) on delete cascade,
  asesor_id         uuid references auth.users(id),
  monto_solicitado  numeric(14,2) not null check (monto_solicitado > 0),
  cuotas            integer not null check (cuotas > 0),
  tasa_interes      numeric(7,4) not null default 0 check (tasa_interes >= 0),
  motivo            text not null,
  estado            text not null default 'pendiente' check (estado in ('pendiente','aprobado','rechazado')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- ----------------------------------------------------------
-- 3. Índices
-- ----------------------------------------------------------
create index cuentas_user_id_idx              on public.cuentas(user_id);
create index transacciones_cuenta_fecha_idx   on public.transacciones(cuenta_id, fecha desc);
create index cuentas_ahorro_user_id_idx       on public.cuentas_ahorro(user_id);
create index movimientos_ahorro_cuenta_idx    on public.movimientos_ahorro(cuenta_id, fecha desc);
create index creditos_user_id_idx             on public.creditos(user_id);
create index cronograma_credito_fecha_idx     on public.cronograma_pagos(credito_id, fecha_vencimiento asc);
create index transferencias_user_id_idx       on public.transferencias(user_id);
create index pagos_servicios_user_id_idx      on public.pagos_servicios(user_id);
create index pagos_user_id_idx                on public.pagos(user_id);
create index tarjetas_user_id_idx             on public.tarjetas(user_id);
create index prestamos_user_id_idx            on public.prestamos(user_id);
create index solicitudes_prestamo_user_idx     on public.solicitudes_prestamo(user_id);
create index solicitudes_prestamo_estado_idx   on public.solicitudes_prestamo(estado);

-- ----------------------------------------------------------
-- 4. Triggers de updated_at
-- ----------------------------------------------------------
create trigger perfiles_set_updated_at
  before update on public.perfiles
  for each row execute function public.set_updated_at();

create trigger cuentas_set_updated_at
  before update on public.cuentas
  for each row execute function public.set_updated_at();

create trigger cuentas_ahorro_set_updated_at
  before update on public.cuentas_ahorro
  for each row execute function public.set_updated_at();

create trigger creditos_set_updated_at
  before update on public.creditos
  for each row execute function public.set_updated_at();

create trigger solicitudes_prestamo_set_updated_at
  before update on public.solicitudes_prestamo
  for each row execute function public.set_updated_at();

-- ----------------------------------------------------------
-- 4.5. Función de seguridad para evitar recursión infinita en las políticas RLS
-- ----------------------------------------------------------
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

-- Triggers para registrar automáticamente el asesor_id al aprobar/crear préstamos
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

create trigger tr_set_prestamo_asesor_id
  before insert on public.prestamos
  for each row execute function public.set_prestamo_asesor_id();

-- ----------------------------------------------------------
-- 5. Row Level Security (RLS)
-- ----------------------------------------------------------
alter table public.perfiles           enable row level security;
alter table public.cuentas            enable row level security;
alter table public.transacciones      enable row level security;
alter table public.cuentas_ahorro     enable row level security;
alter table public.movimientos_ahorro  enable row level security;
alter table public.creditos           enable row level security;
alter table public.cronograma_pagos   enable row level security;
alter table public.transferencias     enable row level security;
alter table public.pagos_servicios    enable row level security;
alter table public.pagos              enable row level security;
alter table public.tarjetas           enable row level security;
alter table public.prestamos          enable row level security;
alter table public.solicitudes_prestamo enable row level security;

-- Perfiles
create policy "perfiles_select" on public.perfiles
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );
create policy "perfiles_insert" on public.perfiles
  for insert to authenticated with check (user_id = auth.uid());
create policy "perfiles_update" on public.perfiles
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Cuentas
create policy "cuentas_select" on public.cuentas
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );
create policy "cuentas_update" on public.cuentas
  for update to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  ) with check (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

-- Transacciones
create policy "transacciones_select" on public.transacciones
  for select to authenticated using (
    exists (select 1 from public.cuentas c where c.id = transacciones.cuenta_id and c.user_id = auth.uid()) or
    public.check_es_asesor(auth.uid()) = true
  );
create policy "transacciones_insert" on public.transacciones
  for insert to authenticated with check (
    exists (select 1 from public.cuentas c where c.id = transacciones.cuenta_id and c.user_id = auth.uid()) or
    public.check_es_asesor(auth.uid()) = true
  );

-- Cuentas Ahorro
create policy "cuentas_ahorro_select" on public.cuentas_ahorro
  for select to authenticated using (user_id = auth.uid());
create policy "cuentas_ahorro_update" on public.cuentas_ahorro
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Movimientos Ahorro
create policy "movimientos_ahorro_select" on public.movimientos_ahorro
  for select to authenticated using (
    exists (select 1 from public.cuentas_ahorro c
            where c.id = movimientos_ahorro.cuenta_id and c.user_id = auth.uid())
  );
create policy "movimientos_ahorro_insert" on public.movimientos_ahorro
  for insert to authenticated with check (
    exists (select 1 from public.cuentas_ahorro c
            where c.id = movimientos_ahorro.cuenta_id and c.user_id = auth.uid())
  );

-- Créditos
create policy "creditos_select" on public.creditos
  for select to authenticated using (user_id = auth.uid());

-- Cronograma
create policy "cronograma_select" on public.cronograma_pagos
  for select to authenticated using (
    exists (select 1 from public.creditos c
            where c.id = cronograma_pagos.credito_id and c.user_id = auth.uid())
  );

-- Transferencias
create policy "transferencias_select" on public.transferencias
  for select to authenticated using (user_id = auth.uid());
create policy "transferencias_insert" on public.transferencias
  for insert to authenticated with check (user_id = auth.uid());

-- Pagos Servicios
create policy "pagos_servicios_select" on public.pagos_servicios
  for select to authenticated using (user_id = auth.uid());
create policy "pagos_servicios_insert" on public.pagos_servicios
  for insert to authenticated with check (user_id = auth.uid());

-- Pagos
create policy "pagos_select" on public.pagos
  for select to authenticated using (user_id = auth.uid());

-- Tarjetas
create policy "tarjetas_select" on public.tarjetas
  for select to authenticated using (user_id = auth.uid());
create policy "tarjetas_insert" on public.tarjetas
  for insert to authenticated with check (user_id = auth.uid());

-- Préstamos
create policy "prestamos_select" on public.prestamos
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );
create policy "prestamos_insert" on public.prestamos
  for insert to authenticated with check (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );

-- Solicitudes Préstamo
create policy "solicitudes_select" on public.solicitudes_prestamo
  for select to authenticated using (
    user_id = auth.uid() or 
    public.check_es_asesor(auth.uid()) = true
  );
create policy "solicitudes_insert" on public.solicitudes_prestamo
  for insert to authenticated with check (user_id = auth.uid());
create policy "solicitudes_update" on public.solicitudes_prestamo
  for update to authenticated using (
    public.check_es_asesor(auth.uid()) = true
  ) with check (
    public.check_es_asesor(auth.uid()) = true
  );

-- ----------------------------------------------------------
-- 6. Permisos de esquema
-- ----------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant select on all tables in schema public to anon;
grant usage on all sequences in schema public to authenticated;

-- ----------------------------------------------------------
-- 7. Función RPC: verificar si una tarjeta está registrada
--    Llamada desde la app sin login previo (anon)
-- ----------------------------------------------------------
create or replace function public.check_tarjeta_registrada(p_tarjeta_last4 text)
returns table (
  existe           boolean,
  email            text,
  nombre_completo  text,
  tipo_documento   text,
  numero_documento text
)
language plpgsql security definer as $$
begin
  return query
  select
    true,
    p.email,
    p.nombre_completo,
    p.tipo_documento,
    p.numero_documento
  from public.perfiles p
  where p.tarjeta_ultimos4 = p_tarjeta_last4
  limit 1;
end;
$$;

grant execute on function public.check_tarjeta_registrada(text) to anon, authenticated;

-- ----------------------------------------------------------
-- 8. Trigger automático: al insertar perfil, crear cuentas vacías
--    (saldo 0.00 — sin datos inventados para usuarios nuevos)
-- ----------------------------------------------------------
create or replace function public.after_perfil_insert_seed()
returns trigger language plpgsql security definer as $$
declare
  v_num_base text;
begin
  -- Si el perfil es un asesor, no creamos cuentas bancarias automáticas
  if new.es_asesor = true then
    return new;
  end if;

  v_num_base := lpad(floor(random() * 999999)::text, 6, '0');

  -- Cuenta corriente en soles (saldo 0)
  insert into public.cuentas (user_id, tipo, numero_cuenta, saldo, moneda)
  values (
    new.user_id,
    'Cuenta Corriente',
    '191-' || v_num_base || '-' || lpad(floor(random()*9999)::text, 4, '0'),
    0.00,
    'PEN'
  );

  -- Cuenta de ahorros (saldo 0)
  insert into public.cuentas_ahorro (user_id, numero_cuenta, saldo, moneda)
  values (
    new.user_id,
    '193-' || lpad(floor(random()*999999)::text, 6, '0') || '-' || lpad(floor(random()*9999)::text, 4, '0'),
    0.00,
    'PEN'
  );

  return new;
end;
$$;

drop trigger if exists on_perfil_created on public.perfiles;
create trigger on_perfil_created
  after insert on public.perfiles
  for each row execute function public.after_perfil_insert_seed();

-- ----------------------------------------------------------
-- 9. USUARIOS DE PRUEBA CON CONTRASEÑAS (Clientes y Asesor)
--    La clave de TODOS los usuarios es: 123456
-- ----------------------------------------------------------
do $$
declare
  uid1 uuid := gen_random_uuid();
  uid2 uuid := gen_random_uuid();
  uid3 uuid := gen_random_uuid();
  uid_asesor uuid := gen_random_uuid();
  hashed_password text;
begin
  -- Hashear la contraseña "123456" con bcrypt
  hashed_password := extensions.crypt('123456', extensions.gen_salt('bf'));

  -- ── Usuario 1 (Ana Garcia) ────────────────────────────────
  delete from auth.users where email = 'user1@cajatacna.com';
  insert into auth.users (
    id, instance_id, aud, role,
    email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, confirmation_token, recovery_token,
    email_change_token_new, email_change
  ) values (
    uid1, '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'user1@cajatacna.com', hashed_password,
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"nombre":"Ana Garcia"}',
    false, '', '', '', ''
  );

  insert into public.perfiles (
    user_id, nombre_completo, email,
    tipo_documento, numero_documento,
    tarjeta_ultimos4, telefono, direccion, es_asesor
  ) values (
    uid1, 'Ana Garcia Lopez', 'user1@cajatacna.com',
    'DNI', '45871234',
    '8484', '987654321', 'Av. Larco 456, Miraflores, Lima', false
  );

  insert into public.tarjetas (user_id, numero, tipo, marca, fecha_vencimiento)
  values (uid1, '**** **** **** 8484', 'Debito', 'Visa', '12/28');

  -- ── Usuario 2 (Carlos Ramos) ──────────────────────────────
  delete from auth.users where email = 'user2@cajatacna.com';
  insert into auth.users (
    id, instance_id, aud, role,
    email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, confirmation_token, recovery_token,
    email_change_token_new, email_change
  ) values (
    uid2, '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'user2@cajatacna.com', hashed_password,
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"nombre":"Carlos Ramos"}',
    false, '', '', '', ''
  );

  insert into public.perfiles (
    user_id, nombre_completo, email,
    tipo_documento, numero_documento,
    tarjeta_ultimos4, telefono, direccion, es_asesor
  ) values (
    uid2, 'Carlos Ramos Flores', 'user2@cajatacna.com',
    'DNI', '31029847',
    '1751', '912345678', 'Jr. Carabaya 123, Cercado de Lima', false
  );

  insert into public.tarjetas (user_id, numero, tipo, marca, fecha_vencimiento)
  values (uid2, '**** **** **** 1751', 'Debito', 'Visa', '06/27');

  -- ── Usuario 3 (Maria Torres) ──────────────────────────────
  delete from auth.users where email = 'user3@cajatacna.com';
  insert into auth.users (
    id, instance_id, aud, role,
    email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, confirmation_token, recovery_token,
    email_change_token_new, email_change
  ) values (
    uid3, '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'user3@cajatacna.com', hashed_password,
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"nombre":"Maria Torres"}',
    false, '', '', '', ''
  );

  insert into public.perfiles (
    user_id, nombre_completo, email,
    tipo_documento, numero_documento,
    tarjeta_ultimos4, telefono, direccion, es_asesor
  ) values (
    uid3, 'Maria Torres Huaman', 'user3@cajatacna.com',
    'DNI', '72938410',
    '5599', '955123456', 'Calle Los Pinos 789, San Isidro, Lima', false
  );

  insert into public.tarjetas (user_id, numero, tipo, marca, fecha_vencimiento)
  values (uid3, '**** **** **** 5599', 'Debito', 'Visa', '09/29');

  -- ── Usuario Asesor (Asesor Principal CAJATACNA) ─────────────────
  delete from auth.users where email = 'asesor@cajatacna.com';
  insert into auth.users (
    id, instance_id, aud, role,
    email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, confirmation_token, recovery_token,
    email_change_token_new, email_change
  ) values (
    uid_asesor, '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'asesor@cajatacna.com', hashed_password,
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"nombre":"Asesor CAJATACNA"}',
    false, '', '', '', ''
  );

  insert into public.perfiles (
    user_id, nombre_completo, email,
    tipo_documento, numero_documento,
    tarjeta_ultimos4, telefono, direccion, es_asesor
  ) values (
    uid_asesor, 'Asesor Principal CAJATACNA', 'asesor@cajatacna.com',
    'DNI', '00000001',
    '0000', '999999999', 'Sede Central CAJATACNA, Miraflores, Lima', true
  );

end;
$$;

commit;

-- ----------------------------------------------------------
-- 10. DATOS DEMO SOLO PARA USUARIOS DE PRUEBA
-- ----------------------------------------------------------
do $$
declare
  u1 uuid;
  u2 uuid;
  u3 uuid;
  c1_pen uuid;
  c1_usd uuid;
  c2_pen uuid;
  c3_pen uuid;
  ahorro1 uuid;
  credito1 uuid;
begin
  -- Obtener IDs de los usuarios de prueba
  select id into u1 from auth.users where email = 'user1@cajatacna.com' limit 1;
  select id into u2 from auth.users where email = 'user2@cajatacna.com' limit 1;
  select id into u3 from auth.users where email = 'user3@cajatacna.com' limit 1;

  if u1 is null then return; end if;

  -- ── Actualizar saldos de user1 ────────────────────────────
  update public.cuentas set saldo = 4580.50, tipo = 'Cuenta Sueldo'
    where user_id = u1 and moneda = 'PEN'
  returning id into c1_pen;

  insert into public.cuentas (user_id, tipo, numero_cuenta, saldo, moneda)
  values (u1, 'Cuenta Dólares', '191-248301-9812', 1200.00, 'USD')
  returning id into c1_usd;

  update public.cuentas_ahorro set saldo = 2500.00
    where user_id = u1;
  select id into ahorro1 from public.cuentas_ahorro where user_id = u1 limit 1;

  -- Transacciones user1
  insert into public.transacciones (cuenta_id, tipo, monto, descripcion, fecha)
  values
    (c1_pen, 'credito', 4500.00, 'Abono de Remuneración',        now() - interval '2 days'),
    (c1_pen, 'debito',   150.00, 'Pago Claro Hogar',             now() - interval '1 day'),
    (c1_pen, 'debito',    45.80, 'Consumo en POS - Metro',       now() - interval '12 hours'),
    (c1_pen, 'credito',  276.30, 'Transferencia Recibida',       now() - interval '5 days'),
    (c1_usd, 'credito',  500.00, 'Transferencia Recibida USD',   now() - interval '3 days');

  -- Movimientos ahorro user1
  if ahorro1 is not null then
    insert into public.movimientos_ahorro (cuenta_id, tipo, monto, descripcion, fecha)
    values
      (ahorro1, 'deposito', 2000.00, 'Depósito Inicial',  now() - interval '10 days'),
      (ahorro1, 'deposito',  500.00, 'Ahorro Mensual',    now() - interval '4 days'),
      (ahorro1, 'interes',    15.60, 'Interés Generado',  now() - interval '1 day');
  end if;

  -- Tarjeta crédito user1
  insert into public.tarjetas (user_id, numero, tipo, marca, fecha_vencimiento)
  values (u1, '**** **** **** 3219', 'Crédito', 'Mastercard', '08/30');

  -- Préstamo personal user1
  insert into public.prestamos (
    user_id, tipo, numero_enmascarado,
    capital_total, capital_pendiente,
    cuota_numero, cuotas_total, fecha_limite,
    capital_cuota, intereses_cuota, seguros_cuota
  ) values (
    u1, 'Préstamo Personal', 'PP-****-4821',
    15000.00, 9350.00, 9, 24,
    current_date + interval '18 days',
    520.00, 86.50, 12.00
  );

  -- Sembrar algunas solicitudes de préstamos de prueba
  insert into public.solicitudes_prestamo (user_id, monto_solicitado, cuotas, motivo, estado, created_at)
  values
    (u1, 8000.00, 18, 'Refacción del hogar', 'pendiente', now() - interval '1 day'),
    (u2, 20000.00, 36, 'Compra de vehículo usado', 'pendiente', now() - interval '5 hours'),
    (u3, 5000.00, 12, 'Estudios de Postgrado', 'aprobado', now() - interval '3 days');

  -- ── Actualizar saldos de user2 ────────────────────────────
  update public.cuentas set saldo = 1250.00, tipo = 'Cuenta Corriente'
    where user_id = u2 and moneda = 'PEN'
  returning id into c2_pen;

  if c2_pen is not null then
    insert into public.transacciones (cuenta_id, tipo, monto, descripcion, fecha)
    values
      (c2_pen, 'credito', 1500.00, 'Depósito en ventanilla', now() - interval '3 days'),
      (c2_pen, 'debito',   250.00, 'Pago recibo de agua',    now() - interval '2 days');
  end if;

  -- ── Actualizar saldos de user3 ────────────────────────────
  update public.cuentas set saldo = 3100.00, tipo = 'Cuenta Corriente'
    where user_id = u3 and moneda = 'PEN'
  returning id into c3_pen;

  if c3_pen is not null then
    insert into public.transacciones (cuenta_id, tipo, monto, descripcion, fecha)
    values
      (c3_pen, 'credito', 3000.00, 'Abono de Remuneración',  now() - interval '1 day'),
      (c3_pen, 'debito',   100.00, 'Pago de servicio luz',   now() - interval '6 hours');
  end if;

end;
$$;

commit;
