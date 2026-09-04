import { BrowserRouter, Routes, Route, NavLink, useLocation } from 'react-router-dom'
import clsx from 'clsx'
import Sidebar from './components/Sidebar'
import Dashboard from './pages/Dashboard'
import DailyLog from './pages/DailyLog'
import Summary from './pages/Summary'
import Settings from './pages/Settings'

// Mobile bottom nav
function MobileNav() {
  const links = [
    { to: '/', label: 'Home', icon: '🏠' },
    { to: '/log', label: 'Log', icon: '📝' },
    { to: '/summary', label: 'Summary', icon: '📊' },
    { to: '/settings', label: 'Settings', icon: '⚙️' },
  ]
  return (
    <nav className="md:hidden fixed bottom-0 inset-x-0 bg-white border-t border-slate-100 flex z-50">
      {links.map(({ to, label, icon }) => (
        <NavLink
          key={to}
          to={to}
          end={to === '/'}
          className={({ isActive }) =>
            clsx(
              'flex-1 flex flex-col items-center justify-center py-2.5 text-xs font-medium transition-colors',
              isActive ? 'text-brand-600' : 'text-slate-400',
            )
          }
        >
          <span className="text-lg leading-none mb-0.5">{icon}</span>
          <span>{label}</span>
        </NavLink>
      ))}
    </nav>
  )
}

function Layout() {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <main className="flex-1 overflow-auto pb-20 md:pb-0">
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/log" element={<DailyLog />} />
          <Route path="/summary" element={<Summary />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </main>
      <MobileNav />
    </div>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <Layout />
    </BrowserRouter>
  )
}
