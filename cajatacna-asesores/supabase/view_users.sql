-- ====================================================================
-- SCRIPT DE CONSULTA DE USUARIOS Y PERFILES EN SUPABASE
-- Copia y pega esto en el SQL Editor de tu proyecto de Supabase para ver los registros.
-- ====================================================================

-- 1. Ver los usuarios autenticados en el sistema de autenticación de Supabase (auth.users)
SELECT 
    id AS user_id, 
    email, 
    created_at, 
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC;

-- 2. Ver la información detallada de los perfiles de la app (tarjeta asociada, DNI, nombre, etc.)
SELECT 
    id AS perfil_id,
    user_id,
    nombre_completo,
    email,
    tipo_documento,
    numero_documento,
    tarjeta_ultimos4,
    telefono,
    direccion,
    fecha_registro
FROM public.perfiles
ORDER BY fecha_registro DESC;
