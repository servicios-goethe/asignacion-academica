import { useEffect, useState } from 'react'
import './App.css'

type Language = 'es' | 'de'
type HealthState = 'loading' | 'ok' | 'error'

type AppConfig = {
  applicationName: string
  version: string
  environment: string
  plannedCapabilities: string[]
}

const apiUrl = import.meta.env.VITE_API_URL ?? (window.location.hostname === 'localhost' ? 'http://localhost:5050' : '')

const copy = {
  es: {
    eyebrow: 'Goethe-Schule Buenos Aires',
    title: 'Asignación Académica',
    subtitle: 'Planificación docente para el ciclo lectivo 2027',
    description: 'Una base clara para declarar disponibilidad, construir la estructura académica y preparar la asignación docente.',
    status: 'Estado del servicio',
    connected: 'API conectada',
    checking: 'Verificando API',
    unavailable: 'API no disponible',
    environment: 'Ambiente',
    cycle: 'Ciclo activo',
    cycleValue: '2027 · preparación',
    login: 'Ingresar con Google',
    loginNote: 'Disponible para cuentas @goethe.edu.ar',
    next: 'Próximamente',
    capabilities: ['Disponibilidad docente', 'Estructura académica anual', 'Asignación por división', 'Exportación para Untis'],
  },
  de: {
    eyebrow: 'Goethe-Schule Buenos Aires',
    title: 'Akademische Zuordnung',
    subtitle: 'Lehrkräfteplanung für das Schuljahr 2027',
    description: 'Eine klare Grundlage für Verfügbarkeiten, die Jahresstruktur und die Lehrkräftezuordnung.',
    status: 'Dienststatus',
    connected: 'API verbunden',
    checking: 'API wird geprüft',
    unavailable: 'API nicht verfügbar',
    environment: 'Umgebung',
    cycle: 'Aktiver Zyklus',
    cycleValue: '2027 · Vorbereitung',
    login: 'Mit Google anmelden',
    loginNote: 'Für Konten @goethe.edu.ar verfügbar',
    next: 'Demnächst',
    capabilities: ['Lehrkräfteverfügbarkeit', 'Jahresstruktur', 'Zuordnung nach Klasse', 'Untis-Export'],
  },
} as const

function App() {
  const [language, setLanguage] = useState<Language>('es')
  const [health, setHealth] = useState<HealthState>('loading')
  const [config, setConfig] = useState<AppConfig | null>(null)
  const t = copy[language]

  useEffect(() => {
    Promise.all([
      fetch(`${apiUrl}/healthz`).then((response) => {
        if (!response.ok) throw new Error('health')
        return response.json()
      }),
      fetch(`${apiUrl}/api/config`).then((response) => {
        if (!response.ok) throw new Error('config')
        return response.json()
      }),
    ])
      .then(([, appConfig]) => {
        setConfig(appConfig)
        setHealth('ok')
      })
      .catch(() => setHealth('error'))
  }, [])

  const healthLabel = health === 'ok' ? t.connected : health === 'error' ? t.unavailable : t.checking

  return (
    <main className="app-shell">
      <header className="topbar">
        <div className="brand-mark" aria-label="Goethe-Schule">G</div>
        <div className="topbar-meta">
          <span className="product-name">{t.title}</span>
          <div className="language-switcher" role="group" aria-label="Idioma">
            <button className={language === 'es' ? 'active' : ''} onClick={() => setLanguage('es')} type="button">ES</button>
            <button className={language === 'de' ? 'active' : ''} onClick={() => setLanguage('de')} type="button">DE</button>
          </div>
        </div>
      </header>

      <section className="hero" aria-labelledby="page-title">
        <div className="hero-copy">
          <p className="eyebrow">{t.eyebrow}</p>
          <h1 id="page-title">{t.title}</h1>
          <p className="subtitle">{t.subtitle}</p>
          <p className="description">{t.description}</p>
          <button className="primary-button" type="button" onClick={() => { window.location.href = `${apiUrl}/auth/login?returnUrl=/` }}>
            <span className="google-g" aria-hidden="true">G</span>
            {t.login}
          </button>
          <p className="login-note">{t.loginNote}</p>
        </div>

        <aside className="status-panel" aria-label={t.status}>
          <div className="status-heading">
            <span className={`status-dot ${health}`} aria-hidden="true" />
            <span>{t.status}</span>
          </div>
          <strong>{healthLabel}</strong>
          <dl>
            <div><dt>{t.environment}</dt><dd>{config?.environment ?? 'Development'}</dd></div>
            <div><dt>{t.cycle}</dt><dd>{t.cycleValue}</dd></div>
            <div><dt>API</dt><dd>{config?.version ?? '0.1.0'}</dd></div>
          </dl>
        </aside>
      </section>

      <section className="roadmap" aria-labelledby="roadmap-title">
        <div className="section-heading">
          <p className="eyebrow">{t.next}</p>
          <h2 id="roadmap-title">{language === 'es' ? 'El flujo que vamos a construir' : 'Der Prozess, den wir aufbauen'}</h2>
        </div>
        <div className="capability-grid">
          {t.capabilities.map((capability, index) => (
            <article className="capability" key={capability}>
              <span className="capability-index">0{index + 1}</span>
              <h3>{capability}</h3>
            </article>
          ))}
        </div>
      </section>

      <footer className="footer">
        <span>Goethe-Schule · {config?.applicationName ?? t.title}</span>
        <span>{language === 'es' ? 'Sprint 1 · Fundación' : 'Sprint 1 · Grundlage'}</span>
      </footer>
    </main>
  )
}

export default App
