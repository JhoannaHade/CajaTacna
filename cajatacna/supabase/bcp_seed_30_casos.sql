-- ====================================================================
-- SEED SCRIPT FOR 30 PRACTICE CASES (CRÉDITO EMPRESARIAL)
-- Run this script in your Supabase SQL Editor to populate the database
-- ====================================================================
begin;

-- Setup helper variable for password hash (123456)
do $$
declare
  v_hashed_password text := extensions.crypt('123456', extensions.gen_salt('bf'));
  v_asesor_id uuid;
  v_user_id uuid;
  v_solicitud_id uuid;
begin
  -- Get the demo advisor ID
  select user_id into v_asesor_id from public.perfiles where email = 'asesor@cajatacna.com' limit 1;
  if v_asesor_id is null then
    raise exception 'Asesor demo no encontrado. Por favor corre primero el script de actualizacion/correccion.';
  end if;

  -- Caso 1: Anaximandro Quispe
  v_user_id := 'a59e2574-ce83-4488-84aa-0aaf5b0d3c21';
  v_solicitud_id := 'e6a8bcb4-9850-43b1-ba1f-81b95cfb7fe0';
  delete from auth.users where email = 'caso1@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso1@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Anaximandro Quispe"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Anaximandro Quispe', 'caso1@cajatacna.com', 'DNI', '40118120', '0001', '964110201', 'Bodega Bodega Don Anaxi, en El Tambo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 1000.0, 12, 43.92, 'Capital de trabajo: compra de mercaderia', 'enviado', 'EXP-401181', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40118120', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 2: Eulalia Mamani
  v_user_id := '7d043fb6-5412-4dc4-8315-f88e3511467f';
  v_solicitud_id := 'b76215b9-4ef0-4583-b715-d75544ae122f';
  delete from auth.users where email = 'caso2@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso2@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Eulalia Mamani"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Eulalia Mamani', 'caso2@cajatacna.com', 'DNI', '41223341', '0002', '964110202', 'Restaurante Picanteria La Eulalia, en Chilca');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 3000.0, 12, 40.92, 'Compra de cocina industrial', 'enviado', 'EXP-412233', 'cliente', 'sin garantia', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41223341', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 3: Teofilo Huaman
  v_user_id := '17c4b68e-167d-4d82-b743-a27cf18e6dc5';
  v_solicitud_id := '42613292-0aaa-4cb3-b3c4-02e974823f1b';
  delete from auth.users where email = 'caso3@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso3@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Teofilo Huaman"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Teofilo Huaman', 'caso3@cajatacna.com', 'DNI', '42330336', '0003', '964110203', 'Carpinteria Maderas Huaman, en Pilcomayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 5000.0, 18, 43.92, 'Maquinaria: sierra y cepillo', 'enviado', 'EXP-423303', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '42330336', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 4: Casandra Flores
  v_user_id := '6f2e7e2d-e278-49e5-96fe-a00163f08876';
  v_solicitud_id := 'bfa05ede-1acb-4fb7-8566-adb6df04c639';
  delete from auth.users where email = 'caso4@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso4@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Casandra Flores"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Casandra Flores', 'caso4@cajatacna.com', 'DNI', '43440349', '0004', '964110204', 'Abarrotes Distribuidora Casandra, en Huancayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 8000.0, 6, 43.92, 'Reposicion de stock por campana', 'enviado', 'EXP-434403', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43440349', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 5: Demostenes Rojas
  v_user_id := '24224249-f9a9-4852-93a7-a137348427d6';
  v_solicitud_id := '92f05381-de99-4c09-af63-3abe92a00390';
  delete from auth.users where email = 'caso5@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso5@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Demostenes Rojas"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Demostenes Rojas', 'caso5@cajatacna.com', 'DNI', '40556071', '0005', '964110205', 'Ferreteria Ferreteria El Constructor, en San Agustin de Cajas');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 10000.0, 12, 43.92, 'Ampliacion de local', 'enviado', 'EXP-405560', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40556071', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 6: Hipatia Condori
  v_user_id := 'd2fc5c7e-b291-4181-b745-99fd680163d9';
  v_solicitud_id := '33fcf4ee-03e1-4832-af5e-5848e01e3cbe';
  delete from auth.users where email = 'caso6@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso6@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Hipatia Condori"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Hipatia Condori', 'caso6@cajatacna.com', 'DNI', '41669066', '0006', '964110206', 'Textil Confecciones Hipatia, en El Tambo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 12000.0, 24, 40.92, 'Compra de maquinas remalladoras', 'enviado', 'EXP-416690', 'cliente', 'hipotecaria', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41669066', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 7: Anibal Vargas
  v_user_id := '116a181e-9efa-45ce-a2a3-30b368177f3c';
  v_solicitud_id := 'd9462e85-6762-4b1e-bf22-0730fde821bb';
  delete from auth.users where email = 'caso7@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso7@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Anibal Vargas"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Anibal Vargas', 'caso7@cajatacna.com', 'DNI', '43773379', '0007', '964110207', 'Transporte Transportes Anibal, en Concepcion');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 15000.0, 18, 43.92, 'Cuota inicial de vehiculo de carga', 'enviado', 'EXP-437733', 'cliente', 'vehicular', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43773379', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 8: Penelope Apaza
  v_user_id := '51482f07-0be4-4a65-a68d-825a0a9149ca';
  v_solicitud_id := '6ca6a7f5-388f-4986-a936-c09dd643f1c3';
  delete from auth.users where email = 'caso8@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso8@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Penelope Apaza"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Penelope Apaza', 'caso8@cajatacna.com', 'DNI', '40886086', '0008', '964110208', 'Avicola Granja Penelope, en Sapallanga');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 18000.0, 24, 43.92, 'Ampliacion de galpon', 'enviado', 'EXP-408860', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40886086', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 9: Heraclito Ccahua
  v_user_id := '6e0156c9-9c1a-4f3b-a396-ffa6d01cc654';
  v_solicitud_id := '6a284b20-766d-4d4f-bf18-f72b15f899a8';
  delete from auth.users where email = 'caso9@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso9@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Heraclito Ccahua"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Heraclito Ccahua', 'caso9@cajatacna.com', 'DNI', '41990091', '0009', '964110209', 'Comercio Importaciones Heraclito, en Huancayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 20000.0, 36, 43.92, 'Capital para nueva sucursal', 'enviado', 'EXP-419900', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41990091', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 10: Cleopatra Soto
  v_user_id := 'df632690-ec21-40ab-bf84-1d8b6d740514';
  v_solicitud_id := 'fd4323dc-d311-4828-9a27-c72e3032286d';
  delete from auth.users where email = 'caso10@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso10@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Cleopatra Soto"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Cleopatra Soto', 'caso10@cajatacna.com', 'DNI', '43003039', '0010', '964110210', 'Farmacia Botica Cleopatra, en Chupaca');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 25000.0, 24, 40.92, 'Equipamiento y stock farmaceutico', 'enviado', 'EXP-430030', 'cliente', 'hipotecaria', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43003039', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 11: Esquilo Ramos
  v_user_id := '925d876f-cb29-4a9a-a681-77793892ea0f';
  v_solicitud_id := '94874cb9-ef5c-4434-b1cf-8c3c92ad9c71';
  delete from auth.users where email = 'caso11@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso11@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Esquilo Ramos"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Esquilo Ramos', 'caso11@cajatacna.com', 'DNI', '40110010', '0011', '964110211', 'Bodega Minimarket Esquilo, en Huayucachi');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 2000.0, 12, 43.92, 'Compra de congeladora', 'enviado', 'EXP-401100', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40110010', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 12: Ariadna Quispe
  v_user_id := '7503e227-dec4-422c-a6a7-175aa775761f';
  v_solicitud_id := 'cf2c02e2-92ff-48e9-ae5f-cd2c41c32ede';
  delete from auth.users where email = 'caso12@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso12@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Ariadna Quispe"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Ariadna Quispe', 'caso12@cajatacna.com', 'DNI', '41226021', '0012', '964110212', 'Peluqueria Estilos Ariadna, en El Tambo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 4000.0, 18, 43.92, 'Mobiliario y equipos de salon', 'enviado', 'EXP-412260', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41226021', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 13: Sofocles Huanca
  v_user_id := '22fb1c08-2f4f-48ff-9967-4c63877a1df4';
  v_solicitud_id := 'e09618a3-f33a-4fe9-87e2-fd0ae0c9a222';
  delete from auth.users where email = 'caso13@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso13@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Sofocles Huanca"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Sofocles Huanca', 'caso13@cajatacna.com', 'DNI', '43336033', '0013', '964110213', 'Panaderia Panaderia Sofocles, en Sicaya');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 6000.0, 12, 40.92, 'Horno rotativo', 'enviado', 'EXP-433360', 'cliente', 'sin garantia', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43336033', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 14: Casiopea Torres
  v_user_id := '18089703-9e11-4c34-856c-9661c2c55eaf';
  v_solicitud_id := 'f16a1772-f58f-4cc0-96fd-bed694e734db';
  delete from auth.users where email = 'caso14@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso14@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Casiopea Torres"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Casiopea Torres', 'caso14@cajatacna.com', 'DNI', '40550055', '0014', '964110214', 'Mecanica Taller Casiopea, en Pilcomayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 7500.0, 6, 43.92, 'Herramienta neumatica', 'enviado', 'EXP-405500', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40550055', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 15: Aristofanes Cruz
  v_user_id := '2b80347e-62e6-4ada-8570-f9208a02304f';
  v_solicitud_id := '4d67e557-526d-47d8-9db9-6a5251ca7872';
  delete from auth.users where email = 'caso15@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso15@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Aristofanes Cruz"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Aristofanes Cruz', 'caso15@cajatacna.com', 'DNI', '41669166', '0015', '964110215', 'Agropecuario Insumos Aristofanes, en Orcotuna');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 9000.0, 24, 43.92, 'Capital para campana agricola', 'enviado', 'EXP-416691', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41669166', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 16: Calipso Mendoza
  v_user_id := 'e809de7d-698b-463c-b240-ef0e3795f091';
  v_solicitud_id := '578257bc-c4ab-4eb1-9a70-ab530dd4dd1c';
  delete from auth.users where email = 'caso16@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso16@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Calipso Mendoza"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Calipso Mendoza', 'caso16@cajatacna.com', 'DNI', '43880088', '0016', '964110216', 'Calzado Calzados Calipso, en Huancayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 11000.0, 18, 40.92, 'Compra de cuero y maquinaria', 'enviado', 'EXP-438800', 'cliente', 'hipotecaria', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43880088', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 17: Demetrio Quispe
  v_user_id := '90ccac8e-78fb-4d9f-b208-d0fb5e9eaa4d';
  v_solicitud_id := '3ca59d5a-a02f-4f30-b770-bb72109ba3c4';
  delete from auth.users where email = 'caso17@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso17@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Demetrio Quispe"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Demetrio Quispe', 'caso17@cajatacna.com', 'DNI', '40119019', '0017', '964110217', 'Comercio Mayorista Demetrio, en Jauja');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 13500.0, 12, 43.92, 'Reposicion de inventario mayorista', 'enviado', 'EXP-401190', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40119019', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 18: Antigona Flores
  v_user_id := '88162561-4d92-4582-b3e1-e62567c7bb2e';
  v_solicitud_id := '0573cf94-d565-451e-9931-21f88b49c08f';
  delete from auth.users where email = 'caso18@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso18@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Antigona Flores"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Antigona Flores', 'caso18@cajatacna.com', 'DNI', '41226126', '0018', '964110218', 'Restaurante Recreo Antigona, en Concepcion');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 16000.0, 36, 43.92, 'Ampliacion y remodelacion', 'enviado', 'EXP-412261', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41226126', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 19: Pitagoras Rojas
  v_user_id := '05df6fb1-89a6-4827-bc46-9fed3b0cfe6c';
  v_solicitud_id := '9e133ea1-9558-417a-b0d7-ffe511b2a95c';
  delete from auth.users where email = 'caso19@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso19@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Pitagoras Rojas"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Pitagoras Rojas', 'caso19@cajatacna.com', 'DNI', '43339033', '0019', '964110219', 'Ferreteria Ferreteria Pitagoras, en El Tambo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 17000.0, 24, 40.92, 'Compra de stock estructural', 'enviado', 'EXP-433390', 'cliente', 'hipotecaria', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43339033', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 20: Berenice Apaza
  v_user_id := '1b3777c7-c773-4342-a140-e21d5a40343c';
  v_solicitud_id := '173d79e0-871f-4118-b83b-9957801f8707';
  delete from auth.users where email = 'caso20@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso20@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Berenice Apaza"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Berenice Apaza', 'caso20@cajatacna.com', 'DNI', '40556056', '0020', '964110220', 'Textil Tejidos Berenice, en San Jeronimo de Tunan');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 19000.0, 18, 43.92, 'Maquinaria de tejido plano', 'enviado', 'EXP-405560', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40556056', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 21: Anaxagoras Huaman
  v_user_id := '7a1569d2-dadf-4dfb-a340-2901b3357e56';
  v_solicitud_id := 'ec140365-c511-4cb3-acb6-4116b7576f8d';
  delete from auth.users where email = 'caso21@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso21@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Anaxagoras Huaman"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Anaxagoras Huaman', 'caso21@cajatacna.com', 'DNI', '43889089', '0021', '964110221', 'Transporte Carga Anaxagoras, en Huancayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 22000.0, 36, 43.92, 'Cuota inicial de camion', 'enviado', 'EXP-438890', 'cliente', 'vehicular', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43889089', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 22: Climene Vargas
  v_user_id := 'fd8c5f2e-1bd5-4fac-9eb4-d0b82e48951a';
  v_solicitud_id := '47962438-4db0-46dc-93db-29ac32121514';
  delete from auth.users where email = 'caso22@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso22@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Climene Vargas"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Climene Vargas', 'caso22@cajatacna.com', 'DNI', '41003001', '0022', '964110222', 'Avicola Avicola Climene, en Sapallanga');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 24000.0, 24, 40.92, 'Equipamiento de planta', 'enviado', 'EXP-410030', 'cliente', 'hipotecaria', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41003001', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 23: Epaminondas Soto
  v_user_id := '1d032e26-69df-472a-9c9f-a90a43a1eed9';
  v_solicitud_id := '5315e9f4-6fed-4952-b1ae-046f77185205';
  delete from auth.users where email = 'caso23@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso23@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Epaminondas Soto"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Epaminondas Soto', 'caso23@cajatacna.com', 'DNI', '40115011', '0023', '964110223', 'Bodega Bodega Epaminondas, en Pucara');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 1500.0, 6, 43.92, 'Compra de vitrinas', 'enviado', 'EXP-401150', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '40115011', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 24: Lisistrata Ramos
  v_user_id := '304c0503-40c3-4fff-924d-1656e3748ac7';
  v_solicitud_id := '250386c1-c520-4334-9731-1e6b8aaa86b7';
  delete from auth.users where email = 'caso24@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso24@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Lisistrata Ramos"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Lisistrata Ramos', 'caso24@cajatacna.com', 'DNI', '41336036', '0024', '964110224', 'Comercio Variedades Lisistrata, en Huancayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 3500.0, 12, 43.92, 'Capital de trabajo', 'enviado', 'EXP-413360', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41336036', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 25: Filoctetes Cruz
  v_user_id := '29ca1ec6-13e9-45ca-9543-0c8d38a510bb';
  v_solicitud_id := '61d31425-7c7b-4f70-93eb-774cf2d4bf90';
  delete from auth.users where email = 'caso25@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso25@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Filoctetes Cruz"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Filoctetes Cruz', 'caso25@cajatacna.com', 'DNI', '41552052', '0025', '964110225', 'Restaurante Cevicheria Filoctetes, en Chilca');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 11000.0, 18, 40.92, 'Ampliacion de local nuevo', 'enviado', 'EXP-415520', 'cliente', 'sin garantia', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41552052', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 26: Calirroe Mendoza
  v_user_id := 'da389d74-88d5-4f2e-b041-162029251892';
  v_solicitud_id := '9ceadfd7-df71-40f2-bf94-2b6c0c0e52c8';
  delete from auth.users where email = 'caso26@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso26@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Calirroe Mendoza"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Calirroe Mendoza', 'caso26@cajatacna.com', 'DNI', '41888088', '0026', '964110226', 'Calzado Calzados Calirroe, en El Tambo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 16000.0, 24, 43.92, 'Maquinaria de mayor capacidad', 'enviado', 'EXP-418880', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41888088', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 27: Tucidides Quispe
  v_user_id := '66ddd7ea-4fb8-4560-962e-496790aff059';
  v_solicitud_id := 'd42c2fa9-1833-4291-8cad-a22a6f47cad6';
  delete from auth.users where email = 'caso27@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso27@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Tucidides Quispe"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Tucidides Quispe', 'caso27@cajatacna.com', 'DNI', '42220022', '0027', '964110227', 'Ferreteria Ferreteria Tucidides, en Concepcion');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 20000.0, 24, 40.92, 'Compra de stock y montacarga', 'enviado', 'EXP-422200', 'cliente', 'hipotecaria', true, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '42220022', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 28: Aquiles Mamani
  v_user_id := '9942b194-e8a5-44fa-b872-effc24e6a3f8';
  v_solicitud_id := '62ccd9e6-5eca-429f-a50c-727b2bc1c2f8';
  delete from auth.users where email = 'caso28@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso28@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Aquiles Mamani"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Aquiles Mamani', 'caso28@cajatacna.com', 'DNI', '43337037', '0028', '964110228', 'Comercio Comercial Aquiles, en Huancayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 15000.0, 24, 43.92, 'Capital de trabajo', 'enviado', 'EXP-433370', 'cliente', 'hipotecaria', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43337037', 'NORMAL', 1, 0.0, 0.0, 0, true, 'Cliente registrado en lista de inhabilitados del sistema financiero', 850, 'Bajo');

  -- Caso 29: Medea Apaza
  v_user_id := 'eb00ab79-0799-44cb-b784-f3ce87cb64fc';
  v_solicitud_id := 'b04728f5-f3a9-4604-b973-8d3272193457';
  delete from auth.users where email = 'caso29@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso29@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Medea Apaza"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Medea Apaza', 'caso29@cajatacna.com', 'DNI', '41884084', '0029', '964110229', 'Bodega Bodega Medea, en Pilcomayo');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 14000.0, 18, 43.92, 'Compra de camioneta para reparto', 'enviado', 'EXP-418840', 'cliente', 'sin garantia', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '41884084', 'NORMAL', 1, 0.0, 0.0, 0, false, NULL, 850, 'Bajo');

  -- Caso 30: Esquines Rojas
  v_user_id := 'e186adae-cfbd-4ffa-b382-b3a9c1d9509e';
  v_solicitud_id := '1e4dcef8-18d7-48fd-baa6-75483a4d5f06';
  delete from auth.users where email = 'caso30@cajatacna.com';
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin) 
  values (v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caso30@cajatacna.com', v_hashed_password, now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Esquines Rojas"}', false);
  insert into public.perfiles (user_id, nombre_completo, email, tipo_documento, numero_documento, tarjeta_ultimos4, telefono, direccion) 
  values (v_user_id, 'Esquines Rojas', 'caso30@cajatacna.com', 'DNI', '43334034', '0030', '964110230', 'Transporte Fletes Esquines, en Jauja');
  insert into public.solicitudes_prestamo (id, user_id, monto_solicitado, cuotas, tasa_interes, motivo, estado, numero_expediente, canal, garantia, seguro_desgravamen, created_at, updated_at) 
  values (v_solicitud_id, v_user_id, 30000.0, 24, 43.92, 'Compra de unidad de transporte', 'enviado', 'EXP-433340', 'cliente', 'vehicular', false, now(), now());
  insert into public.consultas_buro (asesor_id, cliente_id, dni_consultado, calificacion_sbs, entidades_con_deuda, deuda_total_pen, mayor_deuda, dias_mayor_mora, en_lista_negra, motivo_bloqueo, score_sentinel, riesgo) 
  values (v_asesor_id, v_user_id, '43334034', 'NORMAL', 1, 0.0, 0.0, 0, true, 'Cliente registrado en lista de inhabilitados del sistema financiero', 850, 'Bajo');

end $$;
commit;