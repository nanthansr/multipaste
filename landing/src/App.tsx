import LandingPage from './components/LandingPage';
import PrivacyPolicy from './components/PrivacyPolicy';

export default function App() {
  return window.location.pathname === '/privacy'
    ? <PrivacyPolicy />
    : <LandingPage />;
}
