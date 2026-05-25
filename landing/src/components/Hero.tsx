import React from 'react';
import { GUMROAD_URL, PRICE, MACOS_REQUIREMENT } from '../config';

export default function Hero() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center text-center px-5 pt-24 pb-16 overflow-hidden">

      {/* Ambient glow orbs */}
      <div className="glow-indigo absolute -top-32 -left-32 w-[480px] h-[480px] pointer-events-none" />
      <div className="glow-blue absolute top-1/3 right-0 w-[360px] h-[360px] pointer-events-none" />

      {/* Grid mesh */}
      <div className="grid-mesh absolute inset-0 pointer-events-none" />

      <div className="relative z-10 max-w-4xl mx-auto">

        {/* Eyebrow */}
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full mb-8 border border-blue-500/20 bg-blue-950/25 backdrop-blur-sm">
          <span className="w-1.5 h-1.5 rounded-full bg-blue-400 animate-pulse" />
          <span className="text-[11px] font-mono font-semibold text-blue-300 tracking-wide">
            {MACOS_REQUIREMENT} · One-time {PRICE} · No subscription
          </span>
        </div>

        {/* Headline */}
        <h1 className="font-display font-bold text-5xl sm:text-6xl lg:text-7xl tracking-tight leading-[1.1] mb-6 bg-gradient-to-b from-white via-slate-100 to-slate-300 bg-clip-text text-transparent">
          Paste like a surgeon.
        </h1>

        {/* Sub */}
        <p className="max-w-2xl mx-auto text-[17px] sm:text-lg leading-relaxed text-slate-400 mb-10">
          Multipaste is the rapid-fire paste buffer for your next{' '}
          <span className="text-slate-200 font-medium">10 seconds</span>.
          Not your next 10 days.{' '}
          Hold <span className="kbd">⌘⇧</span>, tap <span className="kbd">V</span> to cycle
          your recent clips and release to paste — exactly where your cursor is.
        </p>

        {/* CTAs */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-3 mb-8">
          <a
            href={GUMROAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto flex items-center justify-center gap-2 px-7 py-3 bg-blue-600 hover:bg-blue-500 active:scale-[0.97] text-white text-[15px] font-semibold rounded-full transition-all shadow-lg shadow-blue-600/25 hover:shadow-blue-500/35"
          >
            Buy for Mac — {PRICE}
          </a>
          <a
            href="#how-it-works"
            className="w-full sm:w-auto flex items-center justify-center gap-2 px-7 py-3 bg-white/6 hover:bg-white/10 border border-white/10 hover:border-white/18 text-slate-200 text-[15px] font-semibold rounded-full transition-all backdrop-blur-sm"
          >
            How it works ↓
          </a>
        </div>

        {/* Fine print */}
        <p className="text-xs text-slate-500 font-mono">
          Direct download · Not on the App Store · Accessibility permission required
        </p>
      </div>
    </section>
  );
}
