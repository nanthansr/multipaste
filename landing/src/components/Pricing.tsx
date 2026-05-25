import React from 'react';
import { Check } from 'lucide-react';
import { GUMROAD_URL, PRICE, MACOS_REQUIREMENT } from '../config';

const included = [
  'Cycle & Drop keyboard workflow',
  'Radial HUD circular picker',
  'FIFO sequential paste',
  'Text, images & files support',
  'App exclusion list (password managers safe)',
  'Launch at login',
  'Unlimited clipboard history',
  'On-device SQLite — nothing leaves your Mac',
];

export default function Pricing() {
  return (
    <section id="pricing" className="relative z-10 py-24 px-5 border-t border-white/5">
      <div className="max-w-md mx-auto text-center">

        <h2 className="font-display font-bold text-3xl sm:text-4xl text-white mb-4">
          Simple pricing.
        </h2>
        <p className="text-slate-400 mb-12">
          No subscription. No tiers. No upsell. One price — yours forever.
        </p>

        {/* Pricing card */}
        <div className="glass-panel rounded-2xl overflow-hidden">
          {/* Price header */}
          <div className="px-8 pt-10 pb-8 border-b border-white/8">
            <div className="flex items-end justify-center gap-2 mb-2">
              <span className="font-display font-bold text-5xl text-white">{PRICE}</span>
              <span className="text-slate-400 text-sm mb-1.5">once</span>
            </div>
            <p className="text-[13px] text-slate-500">No subscription · No App Store cut</p>

            <a
              href={GUMROAD_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-6 flex items-center justify-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-500 active:scale-[0.97] text-white text-[14px] font-semibold rounded-full transition-all shadow-lg shadow-blue-600/25 w-full"
            >
              Buy on Gumroad →
            </a>

            <p className="mt-3 text-[11px] text-slate-600 font-mono">
              Secure checkout via Gumroad · Instant download
            </p>
          </div>

          {/* Feature list */}
          <div className="px-8 py-7">
            <p className="text-[11px] font-mono font-semibold uppercase tracking-widest text-slate-500 mb-5 text-left">
              Everything included
            </p>
            <ul className="space-y-3 text-left">
              {included.map(item => (
                <li key={item} className="flex items-start gap-3">
                  <Check className="w-4 h-4 text-emerald-400 mt-0.5 shrink-0" />
                  <span className="text-[13px] text-slate-300">{item}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Fine print */}
          <div className="px-8 py-5 border-t border-white/6 bg-white/2">
            <p className="text-[11px] font-mono text-slate-600 leading-relaxed">
              {MACOS_REQUIREMENT} · Direct download · Accessibility permission required (for global hotkeys) · 14-day free trial — Cycle & Drop is free to evaluate
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
