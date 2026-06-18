import axios from 'axios'

const SUPABASE_URL = 'https://kxsyodhgknxtygxzlmsm.supabase.co'
const SUPABASE_ANON_KEY = 'sb_publishable_UvbgD8Qv9oiURc2gHU1Wpw_Sm7YauHn'

export const TOKEN_KEY = 'cm_token'
export const USER_KEY = 'cm_user'

// Guardar sesión localmente
export function saveSession(token, user) {
  localStorage.setItem(TOKEN_KEY, token)
  localStorage.setItem(USER_KEY, JSON.stringify(user))
}

// Limpiar sesión localmente
export function clearSession() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(USER_KEY)
}

// Obtener token guardado
export function getStoredToken() {
  return localStorage.getItem(TOKEN_KEY)
}

// Obtener usuario guardado
export function getStoredUser() {
  try {
    const raw = localStorage.getItem(USER_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

// Configurar cabeceras de Supabase
function getHeaders() {
  const token = getStoredToken()
  return {
    'Content-Type': 'application/json',
    'apikey': SUPABASE_ANON_KEY,
    ...(token ? { 'Authorization': `Bearer ${token}` } : {})
  }
}

// --- Autenticación ---
export async function login(email, password) {
  // 1. Iniciar sesión en Supabase Auth con el correo y contraseña
  const authRes = await axios.post(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    email: email,
    password: password
  }, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Content-Type': 'application/json'
    }
  })

  const token = authRes.data.access_token
  const userId = authRes.data.user.id

  // 2. Obtener el perfil para verificar que es asesor
  const perfilRes = await axios.get(`${SUPABASE_URL}/rest/v1/perfiles?user_id=eq.${userId}`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  })

  if (perfilRes.data.length === 0) {
    throw new Error('No se encontró el perfil de usuario en la base de datos.')
  }

  const perfil = perfilRes.data[0]
  if (!perfil.es_asesor) {
    throw new Error('Acceso Denegado: Su cuenta no cuenta con permisos de Asesor.')
  }

  const user = {
    id: perfil.user_id,
    codigo_empleado: perfil.numero_documento,
    nombres: perfil.nombre_completo.split(' ')[0] || perfil.nombre_completo,
    apellidos: perfil.nombre_completo.split(' ').slice(1).join(' ') || '',
    nombre: perfil.nombre_completo,
    perfil: 'asesor',
    email: perfil.email
  }

  return { token, user }
}


// --- Solicitudes de Préstamo ---
export async function listarSolicitudes() {
  const headers = getHeaders()
  const [solRes, perfRes] = await Promise.all([
    axios.get(`${SUPABASE_URL}/rest/v1/solicitudes_prestamo?order=created_at.desc`, { headers }),
    axios.get(`${SUPABASE_URL}/rest/v1/perfiles`, { headers })
  ])

  // Crear mapa de perfiles para resolver nombres
  const perfilesMap = {}
  perfRes.data.forEach(p => {
    perfilesMap[p.user_id] = p.nombre_completo
  })

  return solRes.data.map(s => ({
    id: s.id,
    numero_expediente: `EXP-${s.id.substring(0, 6).toUpperCase()}`,
    cliente_nombre: perfilesMap[s.user_id] || 'Cliente Desconocido',
    asesor_nombre: perfilesMap[s.asesor_id] || 'Por asignar',
    monto_solicitado: Number(s.monto_solicitado),
    monto_aprobado: s.estado === 'aprobado' ? Number(s.monto_solicitado) : null,
    cuotas: s.cuotas,
    tasa_interes: Number(s.tasa_interes),
    motivo: s.motivo,
    estado: s.estado,
    created_at: s.created_at
  }))
}

export async function crearSolicitud(payload) {
  const headers = getHeaders()
  const user = getStoredUser()

  // Mapear campos esperados por la BD
  const body = {
    user_id: payload.cliente_id || user.id, // ID del cliente
    monto_solicitado: payload.monto,
    cuotas: payload.cuotas,
    tasa_interes: payload.tasa || 15.5,
    motivo: payload.motivo || 'Préstamo comercial web',
    estado: 'pendiente'
  }

  const { data } = await axios.post(`${SUPABASE_URL}/rest/v1/solicitudes_prestamo`, body, { headers })
  return data
}

// Notas simuladas en LocalStorage para cada solicitud
export async function listarNotas(solicitudId) {
  const key = `notes_${solicitudId}`
  const raw = localStorage.getItem(key)
  return raw ? JSON.parse(raw) : []
}

export async function agregarNota(solicitudId, contenido) {
  const key = `notes_${solicitudId}`
  const current = await listarNotas(solicitudId)
  const user = getStoredUser()
  const newNote = {
    contenido,
    autor: user.nombre,
    created_at: new Date().toISOString()
  }
  current.push(newNote)
  localStorage.setItem(key, JSON.stringify(current))
  return newNote
}

// --- Préstamos Activos (Dashboard Completo) ---
export async function listarPrestamos() {
  const headers = getHeaders()
  const [prestRes, perfRes] = await Promise.all([
    axios.get(`${SUPABASE_URL}/rest/v1/prestamos?order=created_at.desc`, { headers }),
    axios.get(`${SUPABASE_URL}/rest/v1/perfiles`, { headers })
  ])

  const perfilesMap = {}
  perfRes.data.forEach(p => {
    perfilesMap[p.user_id] = p.nombre_completo
  })

  return prestRes.data.map(p => ({
    id: p.id,
    numero_prestamo: p.numero_enmascarado,
    tipo: p.tipo,
    cliente_nombre: perfilesMap[p.user_id] || 'Cliente Desconocido',
    asesor_nombre: perfilesMap[p.asesor_id] || 'Automático / Sistema',
    monto_original: Number(p.capital_total),
    saldo_pendiente: Number(p.capital_pendiente),
    cuotas_totales: p.cuotas_total,
    cuota_actual: p.cuota_numero,
    fecha_limite: p.fecha_limite,
    created_at: p.created_at
  }))
}

// --- Cartera de Clientes ---
export async function listarCartera(fecha) {
  const headers = getHeaders()
  const user = getStoredUser()

  if (!user) return []

  // 1. Obtener la cartera diaria asignada al asesor
  const carteraRes = await axios.get(
    `${SUPABASE_URL}/rest/v1/cartera_diaria?asesor_id=eq.${user.id}`,
    { headers }
  )

  // 2. Obtener los perfiles de clientes para resolver nombres y documentos
  const { data: perfiles } = await axios.get(
    `${SUPABASE_URL}/rest/v1/perfiles?es_asesor=eq.false`,
    { headers }
  )

  const perfilesMap = {}
  perfiles.forEach((p) => {
    perfilesMap[p.user_id] = p
  })

  return carteraRes.data.map((c) => {
    const cl = perfilesMap[c.cliente_id] || {}
    return {
      id: c.id,
      cliente_id: c.cliente_id,
      cliente_nombre: cl.nombre_completo || 'Cliente BCP',
      documento: cl.numero_documento || '',
      telefono: cl.telefono || '987 654 321',
      direccion: cl.direccion || 'Av. República de Panamá 148, San Isidro',
      estado_visita: c.estado_visita || 'pendiente',
      prioridad: c.prioridad || 'Media',
      score_prioridad: c.score_prioridad || 50,
      monto_credito: Number(c.monto_credito || 5000),
      tipo_gestion: c.tipo_gestion,
      resultado_visita: c.resultado_visita,
      observacion_visita: c.observacion_visita
    }
  })
}

export async function marcarVisita(carteraId, payload) {
  const headers = getHeaders()
  const body = {
    estado_visita: 'visitado',
    resultado_visita: payload.resultado || 'compromiso_pago',
    observacion_visita: payload.observacion || '',
    timestamp_visita: new Date().toISOString(),
    lat_visita: payload.lat || null,
    lng_visita: payload.lng || null
  }

  const { data } = await axios.patch(
    `${SUPABASE_URL}/rest/v1/cartera_diaria?id=eq.${carteraId}`,
    body,
    { headers }
  )
  return { status: 'success', message: 'Visita guardada', data }
}

// --- Ficha de Clientes ---
export async function obtenerCliente(clienteId) {
  const headers = getHeaders()
  // Buscar en perfiles por ID
  const { data } = await axios.get(`${SUPABASE_URL}/rest/v1/perfiles?user_id=eq.${clienteId}`, { headers })
  if (data.length > 0) {
    const p = data[0]
    return {
      id: p.user_id,
      nombre: p.nombre_completo,
      documento: p.numero_documento,
      tipo_documento: p.tipo_documento,
      email: p.email,
      telefono: p.telefono || '987 654 321',
      direccion: p.direccion || 'Calle Los Pinos 789, Lima',
      estado_civil: 'Soltero',
      ingresos_estimados: 3500.00
    }
  }
  return null
}

export async function obtenerFicha(clienteId) {
  return obtenerCliente(clienteId)
}

// --- Evaluación Crediticia (Conectada a la BD de Supabase) ---
export async function consultarBuro(payload) {
  const headers = getHeaders()
  const user = getStoredUser()

  if (!user) throw new Error('No se encontró sesión activa')

  // Buscar si ya existe una consulta de buró para el DNI especificado
  const checkRes = await axios.get(
    `${SUPABASE_URL}/rest/v1/consultas_buro?dni_consultado=eq.${payload.documento}`,
    { headers }
  )

  if (checkRes.data.length > 0) {
    return checkRes.data[0]
  }

  // Si no existe, crear una simulación dinámica real y guardarla en Supabase
  const score = 520 + Math.floor(Math.random() * 320) // score entre 520 y 840
  let riesgo = 'Bajo'
  if (score < 600) riesgo = 'Alto'
  else if (score < 720) riesgo = 'Medio'

  const body = {
    asesor_id: user.id,
    cliente_id: payload.cliente_id || user.id,
    dni_consultado: payload.documento,
    calificacion_sbs: score > 700 ? 'Normal' : 'CPP',
    entidades_con_deuda: score > 700 ? 1 : 3,
    deuda_total_pen: score > 700 ? 1200.00 : 8500.00,
    mayor_deuda: score > 700 ? 1000.00 : 5000.00,
    dias_mayor_mora: score > 700 ? 0 : 25,
    en_lista_negra: score < 580,
    motivo_bloqueo: score < 580 ? 'Cliente reportado con deudas en cobranza coactiva' : null,
    score_sentinel: score,
    riesgo: riesgo
  }

  const { data } = await axios.post(
    `${SUPABASE_URL}/rest/v1/consultas_buro`,
    body,
    { headers }
  )
  return data || body
}

export async function preEvaluar(payload) {
  const ingresos = Number(payload.ingresos || 0)
  const monto = Number(payload.monto || 0)
  const cuotas = Number(payload.cuotas || 12)
  const cuota = (monto * 1.15) / cuotas // Estimación con interés aproximado
  const capacidad = ingresos * 0.4 - cuota // capacidad del 40% del ingreso

  const buro = await consultarBuro({
    documento: payload.documento,
    cliente_id: payload.cliente_id
  })

  const aprobado = capacidad > 0 && !buro.en_lista_negra && buro.score_sentinel > 600

  let dictamen = 'Cliente pre-califica con capacidad de pago óptima y buen historial crediticio.'
  if (buro.en_lista_negra) {
    dictamen = `Rechazado: ${buro.motivo_bloqueo}`
  } else if (buro.score_sentinel <= 600) {
    dictamen = 'Rechazado: Historial crediticio deficiente (Score Sentinel bajo).'
  } else if (capacidad <= 0) {
    dictamen = `Rechazado: Capacidad de pago insuficiente para la cuota estimada de S/ ${cuota.toFixed(2)}`
  }

  return {
    aprobado,
    capacidad_pago: capacidad > 0 ? capacidad : 0,
    score: buro.score_sentinel,
    dictamen
  }
}

// --- Productividad y Comisiones ---
export async function productividad() {
  const prestamos = await listarPrestamos()
  const solicitudes = await listarSolicitudes()
  const totalMonto = prestamos.reduce((sum, p) => sum + p.monto_original, 0)
  const aprobadas = solicitudes.filter(s => s.estado === 'aprobado' || s.estado === 'desembolsado').length

  return {
    metas: { colocacion: 100000, expedientes: 8 },
    avance: { colocacion: totalMonto, expedientes: aprobadas },
    comisiones_acumuladas: totalMonto * 0.01 // 1% de comisión real sobre colocación
  }
}

// --- Cobranza / Mora ---
export async function listarMora() {
  const headers = getHeaders()

  // 1. Obtener préstamos activos
  const { data: prestamos } = await axios.get(
    `${SUPABASE_URL}/rest/v1/prestamos?capital_pendiente=gt.0`,
    { headers }
  )

  // 2. Obtener perfiles de clientes
  const { data: perfiles } = await axios.get(
    `${SUPABASE_URL}/rest/v1/perfiles?es_asesor=eq.false`,
    { headers }
  )

  const perfilesMap = {}
  perfiles.forEach((p) => {
    perfilesMap[p.user_id] = p
  })

  // Retornamos préstamos simulando atrasos si es necesario
  return prestamos.map((p, idx) => {
    const cl = perfilesMap[p.user_id] || {}
    return {
      id: p.id,
      cliente_id: p.user_id,
      cliente_nombre: cl.nombre_completo || 'Cliente BCP',
      documento: cl.numero_documento || '',
      cuotas_vencidas: 1,
      monto_mora: Number((p.capital_pendiente * 0.08).toFixed(2)), // 8% en mora estimado
      dias_atraso: 8 + (idx * 5) % 30,
      numero_prestamo: p.numero_enmascarado
    }
  })
}

export async function registrarAccion(payload) {
  const headers = getHeaders()
  const user = getStoredUser()

  if (!user) throw new Error('No se encontró sesión activa')

  const body = {
    asesor_id: user.id,
    cliente_id: payload.cliente_id,
    tipo_gestion: payload.tipo || 'llamada',
    resultado: payload.resultado || 'compromiso_pago',
    monto_pagado: Number(payload.monto_pagado || 0),
    fecha_compromiso: payload.fecha_compromiso || null,
    monto_compromiso: Number(payload.monto_compromiso || 0),
    observaciones: payload.observaciones || '',
    timestamp_gestion: new Date().toISOString()
  }

  const { data } = await axios.post(
    `${SUPABASE_URL}/rest/v1/acciones_cobranza`,
    body,
    { headers }
  )
  return { status: 'success', message: 'Gestión de cobranza registrada', data }
}



