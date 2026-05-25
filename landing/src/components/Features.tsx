import React from 'react';
import { Zap, Circle, AlignLeft, Image, Shield, Timer } from 'lucide-react';

const features = [
  {
    icon: Zap,
    color: 'text-blue-400 bg-blue-500/10 border-blue-500/20',
    title: 'Cycle & Drop',
    body: 'Hold ⌘⇧ and tap V repeatedly to step through your recent clips. A translucent tooltip floats at your cursor. Release to paste.',
    tag: 'Core workflow',
  },
  {
    icon: Circle,
    color: 'text-violet-400 bg-violet-500/10 border-violet-500/20',
    title: 'Radial HUD picker',
    body: 'Hold the hotkey for ~300ms and a circular wheel of 7 recent clips appears. Point to the one you want and release. Zero hunting.',
    tag: 'Quick access',
  },
  {
    icon: AlignLeft,
    color: 'text-indigo-400 bg-indigo-500/10 border-indigo-500/20',
    title: 'FIFO sequential paste',
    body: 'Copy A, B, C in order — then ⌘V three times to paste them in sequence. Fills multi-field forms at machine speed.',
    tag: 'Power user',
    wide: true,
  },
  {
    icon: Image,
    color: 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20',
    title: 'Multi-format clips',
    body: 'Text, code snippets, hex colors, images, and files. Multipaste handles all pasteboard types your Mac supports.',
    tag: 'All formats',
  },
  {
    icon: Shield,
    color: 'text-rose-400 bg-rose-500/10 border-rose-500/20',
    title: 'Privacy-first design',
    body: 'Everything lives in a local SQLite database on your Mac. Password managers (1Password, Bitwarden, Keychain) are auto-excluded. You control the list.',
    tag: 'Local only',
  },
  {
    icon: Timer,
    color: 'text-amber-400 bg-amber-500/10 border-amber-500/20',
    title: 'Zero-latency activation',
    body: 'The event tap runs natively in the macOS input stack. There is no polling delay — the tooltip is at your cursor before you consciously notice.',
    tag: 'Native macOS',
  },
];

export default function Features() {
  return (
    <section id="features" className="relative z-10 py-24 px-5 border-t border-white/5">
      <div className="max-w-5xl mx-auto">

        {/* Header */}
        <div className="text-center mb-14">
          <h2 className="font-display font-bold text-3xl sm:text-4xl text-white mb-4">
            Everything the clipboard was missing.
          </h2>
          <p className="text-slate-400 text-base max-w-xl mx-auto">
            Multipaste adds the interaction layer that macOS has always lacked — right at the hotkey level.
          </p>
        </div>

        {/* Bento grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {features.map(f => {
            const Icon = f.icon;
            return (
              <div
                key={f.title}
                className={`glass-card rounded-2xl p-6 flex flex-col gap-4 ${f.wide ? 'lg:col-span-1' : ''}`}
              >
                <div className="flex items-start justify-between">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center border ${f.color}`}>
                    <Icon className="w-4 h-4" />
                  </div>
                  <span className="text-[9px] font-mono font-semibold uppercase tracking-widest text-slate-600">
                    {f.tag}
                  </span>
                </div>
                <div>
                  <h3 className="font-display font-semibold text-[15px] text-white mb-2">{f.title}</h3>
                  <p className="text-[13px] text-slate-400 leading-relaxed">{f.body}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
