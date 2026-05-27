import React from 'react';
import Footer from './Footer';

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="mb-10">
      <h2 className="font-display font-semibold text-xl text-white mb-4">{title}</h2>
      <div className="text-[14px] text-slate-400 leading-[1.75] space-y-3">{children}</div>
    </div>
  );
}

export default function PrivacyPolicy() {
  return (
    <div className="min-h-screen">
      {/* Simple nav */}
      <div className="glass-nav sticky top-0 z-50">
        <div className="max-w-3xl mx-auto px-5 py-3.5 flex items-center justify-between">
          <a href="/" className="flex items-center gap-2 group">
            <div className="w-7 h-7 rounded-[8px] bg-gradient-to-br from-blue-500 via-indigo-500 to-violet-600 flex items-center justify-center">
              <span className="text-white font-display font-bold text-sm">M</span>
            </div>
            <span className="font-display font-bold text-[15px] text-slate-200">Multipaste</span>
          </a>
          <a href="/" className="text-[13px] text-slate-500 hover:text-slate-200 transition-colors">
            ← Back to home
          </a>
        </div>
      </div>

      <main className="max-w-3xl mx-auto px-5 py-16">
        {/* Header */}
        <div className="mb-12">
          <h1 className="font-display font-bold text-3xl sm:text-4xl text-white mb-3">
            Privacy Policy
          </h1>
          <p className="text-slate-500 text-[13px] font-mono">Last updated: May 2026</p>
          <p className="text-slate-400 mt-4 text-[15px] leading-relaxed">
            Multipaste is built on a simple principle: your clipboard is your business, not ours.
            Here's exactly what the app collects and what happens to it.
          </p>
        </div>

        <Section title="Clipboard data">
          <p>
            <strong className="text-slate-200">Your clipboard contents never leave your Mac.</strong>{' '}
            Every clip Multipaste captures is stored in a local SQLite database at{' '}
            <code className="kbd text-[11px]">~/Library/Application Support/Multipaste/clips.db</code>.
            No clipboard content is transmitted to any server, ever.
          </p>
          <p>
            Multipaste automatically respects macOS's <em>concealed</em> and <em>transient</em>{' '}
            pasteboard types — so password fields, secure inputs, and system-marked private content
            are never captured.
          </p>
          <p>
            You can clear your entire clip history at any time from the menu bar icon → Clear History.
            Uninstalling the app and deleting the database file removes all local data permanently.
          </p>
        </Section>

        <Section title="App exclusion list">
          <p>
            Certain apps are excluded from clipboard capture by default: 1Password, Bitwarden,
            Keychain Access, and other known password managers. You can view and edit this list in
            Settings → Exclusions. Excluded apps' clipboard activity is never captured or stored.
          </p>
        </Section>

        <Section title="Analytics (anonymous)">
          <p>
            Multipaste sends anonymous usage telemetry to <strong className="text-slate-300">PostHog</strong>.
          </p>
          <p>What is collected:</p>
          <ul className="list-disc list-inside space-y-1 ml-2">
            <li>App version and macOS version</li>
            <li>Feature usage events (e.g. "Cycle & Drop activated", "Radial HUD opened")</li>
            <li>Crash-related signals</li>
          </ul>
          <p>What is <strong className="text-slate-300">never</strong> collected:</p>
          <ul className="list-disc list-inside space-y-1 ml-2">
            <li>Any clipboard content</li>
            <li>Source app names or bundle identifiers</li>
            <li>Your identity, name, or email</li>
          </ul>
          <p>
            You can opt out of analytics entirely in Settings → General → Enable anonymous analytics.
            PostHog processes data under GDPR-compliant terms.
          </p>
        </Section>

        <Section title="Purchase data">
          <p>
            Multipaste is sold through <strong className="text-slate-300">Gumroad</strong>.
            When you purchase, Gumroad processes your payment and sends us your email address
            and a license key. We store these in a Supabase database solely for license
            verification purposes. We do not store payment card details (Gumroad handles that).
          </p>
          <p>
            Your email is used only for license delivery and support — never for marketing.
          </p>
        </Section>

        <Section title="Website feedback">
          <p>
            If you submit feedback via the form on this website, your message and a generic
            "web" device identifier are stored in our Supabase database. No other data is
            attached to feedback submissions.
          </p>
        </Section>

        <Section title="Data retention">
          <ul className="list-disc list-inside space-y-1 ml-2">
            <li>Local clipboard data: controlled entirely by you; persists until you clear it or uninstall</li>
            <li>Analytics events: standard TelemetryDeck / PostHog retention (90 days)</li>
            <li>Purchase records: retained for license verification; contact us to request deletion</li>
            <li>Feedback messages: retained indefinitely; contact us to request deletion</li>
          </ul>
        </Section>

        <Section title="Contact">
          <p>
            Questions about this policy or requests to delete your data:{' '}
            <a
              href="mailto:nanthansr@gmail.com"
              className="text-blue-400 hover:text-blue-300 transition-colors"
            >
              nanthansr@gmail.com
            </a>
          </p>
        </Section>
      </main>

      <Footer />
    </div>
  );
}
