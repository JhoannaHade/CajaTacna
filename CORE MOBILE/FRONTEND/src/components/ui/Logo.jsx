export default function Logo({
  size = 44,
  wordmark = true,
  variant = 'dark',
  subtitle = 'CORE FINANCIERO',
}) {
  const brandColor = variant === 'light' ? '#ffffff' : '#D21E20'
  const textColor = variant === 'light' ? '#ffffff' : '#D21E20'
  const subColor = variant === 'light' ? 'rgba(255,255,255,.8)' : '#667085'
  const nameSize = Math.round(size * 0.48)
  const subSize = Math.max(9, Math.round(size * 0.22))

  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 10 }}>
      {/* Isotipo Caja Tacna */}
      <svg width={size} height={size} viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg" aria-label="Caja Tacna" role="img">
        {/* Círculo superior (cabeza / moneda) */}
        <circle cx="24" cy="9.5" r="4.5" fill={brandColor} />
        {/* Barra horizontal superior */}
        <rect x="10" y="16.5" width="28" height="4" rx="1.5" fill={brandColor} />
        {/* Columna vertical izquierda */}
        <rect x="13.5" y="20.5" width="4.5" height="15" fill={brandColor} />
        {/* Columna vertical derecha */}
        <rect x="30" y="20.5" width="4.5" height="15" fill={brandColor} />
        {/* Barra horizontal intermedia */}
        <rect x="18" y="26" width="12" height="4" fill={brandColor} />
        {/* Barra horizontal inferior */}
        <rect x="10" y="35.5" width="28" height="4" rx="1.5" fill={brandColor} />
      </svg>

      {wordmark && (
        <span style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.05 }}>
          <span style={{ fontWeight: 900, fontSize: nameSize, color: textColor, letterSpacing: '-0.5px', fontFamily: 'Inter, sans-serif' }}>
            Caja Tacna
          </span>
          {subtitle && (
            <span style={{ fontSize: subSize, fontWeight: 700, color: subColor, letterSpacing: '1px', fontFamily: 'Inter, sans-serif' }}>
              {subtitle}
            </span>
          )}
        </span>
      )}
    </span>
  )
}
