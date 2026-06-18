import { useState, useEffect, useCallback } from 'react'
import { Landmark, RefreshCw, BadgePercent, Coins, Users } from 'lucide-react'
import PageHead from '../components/layout/PageHead.jsx'
import Loader from '../components/ui/Loader.jsx'
import Alert from '../components/ui/Alert.jsx'
import Money from '../components/ui/Money.jsx'
import { listarPrestamos } from '../services/supabaseService.js'
import { extractError, formatDate } from '../utils/format.js'

export default function PrestamosPage() {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const cargar = useCallback(() => {
    setLoading(true)
    setError(null)
    listarPrestamos()
      .then((data) => setItems(data || []))
      .catch((err) => setError(extractError(err)))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    cargar()
  }, [cargar])

  // Calcular estadísticas
  const totalDesembolsado = items.reduce((acc, p) => acc + (p.monto_original || 0), 0)
  const totalPendiente = items.reduce((acc, p) => acc + (p.saldo_pendiente || 0), 0)
  const totalClientes = new Set(items.map(p => p.cliente_nombre)).size

  return (
    <>
      <PageHead
        title="Dashboard de Préstamos"
        subtitle="Monitoreo de créditos vigentes y asesores responsables"
        icon={Landmark}
        actions={
          <button className="hb-btn hb-btn-gray hb-btn-sm" onClick={cargar}>
            <RefreshCw size={15} /> Actualizar
          </button>
        }
      />

      {error && <Alert tipo="error">{error}</Alert>}

      {loading ? (
        <Loader text="Cargando préstamos vigentes…" />
      ) : (
        <>
          {/* Tarjetas de Estadísticas (KPIs) */}
          <div className="cm-kpis" style={{ marginBottom: 24 }}>
            <div className="cm-kpi">
              <span className="cm-kpi-ico" style={{ background: '#e6f7f6', color: '#00a9a5' }}>
                <Coins size={24} />
              </span>
              <div>
                <div className="cm-kpi-label">Total Colocado</div>
                <span className="cm-kpi-val"><Money value={totalDesembolsado} /></span>
                <small>Capital desembolsado</small>
              </div>
            </div>

            <div className="cm-kpi" style={{ borderLeftColor: '#f7941e' }}>
              <span className="cm-kpi-ico" style={{ background: '#fef3e2', color: '#f7941e' }}>
                <BadgePercent size={24} />
              </span>
              <div>
                <div className="cm-kpi-label">Saldo Pendiente</div>
                <span className="cm-kpi-val"><Money value={totalPendiente} /></span>
                <small>Capital por cobrar</small>
              </div>
            </div>

            <div className="cm-kpi" style={{ borderLeftColor: '#8e24aa' }}>
              <span className="cm-kpi-ico" style={{ background: '#f3e6f7', color: '#8e24aa' }}>
                <Users size={24} />
              </span>
              <div>
                <div className="cm-kpi-label">Clientes Únicos</div>
                <span className="cm-kpi-val">{totalClientes}</span>
                <small>Con créditos activos</small>
              </div>
            </div>

            <div className="cm-kpi" style={{ borderLeftColor: '#e2132b' }}>
              <span className="cm-kpi-ico" style={{ background: '#fde8eb', color: '#e2132b' }}>
                <Landmark size={24} />
              </span>
              <div>
                <div className="cm-kpi-label">Préstamos Emitidos</div>
                <span className="cm-kpi-val">{items.length}</span>
                <small>Créditos aprobados en total</small>
              </div>
            </div>
          </div>

          {/* Tabla de Préstamos */}
          {items.length === 0 ? (
            <div className="hb-card hb-table-empty">
              No se encontraron préstamos vigentes en la base de datos de Supabase.
            </div>
          ) : (
            <div className="hb-card" style={{ padding: 0 }}>
              <div className="hb-table-wrap">
                <table className="hb-table">
                  <thead>
                    <tr>
                      <th>Préstamo</th>
                      <th>Cliente</th>
                      <th>Tipo</th>
                      <th className="num">Desembolsado</th>
                      <th className="num">Saldo Pendiente</th>
                      <th>Cuotas</th>
                      <th>Asesor Autorizante</th>
                      <th>Fecha</th>
                    </tr>
                  </thead>
                  <tbody>
                    {items.map((p) => (
                      <tr key={p.id}>
                        <td><strong>{p.numero_prestamo}</strong></td>
                        <td>{p.cliente_nombre}</td>
                        <td>
                          <span style={{ fontSize: 13, color: 'var(--hb-muted)' }}>
                            {p.tipo}
                          </span>
                        </td>
                        <td className="num" style={{ fontWeight: '600' }}>
                          <Money value={p.monto_original} />
                        </td>
                        <td className="num" style={{ color: p.saldo_pendiente > 0 ? '#f7941e' : '#4caf50', fontWeight: '600' }}>
                          <Money value={p.saldo_pendiente} />
                        </td>
                        <td>
                          <span className="hb-pill" style={{ background: '#e0f2fe', color: '#0369a1', fontWeight: 'bold' }}>
                            {p.cuota_actual} / {p.cuotas_totales}
                          </span>
                        </td>
                        <td>
                          <span style={{ color: 'var(--hb-primary)', fontWeight: '500' }}>
                            {p.asesor_nombre}
                          </span>
                        </td>
                        <td>{formatDate(p.created_at || p.fecha_limite)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </>
      )}
    </>
  )
}
