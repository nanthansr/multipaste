import React from 'react';

const steps = [
  {
    n: '01',
    title: 'Copy anything.',
    body: 'Text, code snippets, hex colors, image references, file paths. Multipaste silently captures everything in the background as you work — no setup, no friction.',
    detail: 'Running quietly in your menu bar',
  },
  {
    n: '02',
    title: 'Hold ⌘⇧, tap V to cycle.',
    body: 'A glass tooltip appears at your text cursor showing the current clip. Tap V again to step backward through your recent history. The tooltip moves with your cursor.',
    detail: 'Tooltip appears exactly at your caret',
    hotkey: true,
  },
  {
    n: '03',
    title: 'Release to paste.',
    body: 'Let go of ⌘⇧ and the selected clip is pasted precisely where your cursor sits — in any app, in any text field. Zero flow break, pure muscle memory.',
    detail: 'Works in every macOS app',
  },
];

const extras = [
  {
    emoji: '🌀',
    title: 'Radial HUD',
    body: 'Hold the modifiers for ~300ms and a circular picker wheels up — 7 recent clips arranged in a ring. Point and release.',
  },
  {
    emoji: '📋',
    title: 'FIFO sequential paste',
    body: 'Copy A, copy B, copy C. Then ⌘V three times. Pastes A, then B, then C — in order. Perfect for filling forms at machine speed.',
  },
];

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="relative z-10 py-24 px-5">
      <div className="max-w-5xl mx-auto">

        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="font-display font-bold text-3xl sm:text-4xl text-white mb-4">
            Three keystrokes. Infinite speed.
          </h2>
          <p className="text-slate-400 text-base max-w-xl mx-auto">
            There's no mode to enter, no window to open. Just the clipboard workflow you already have — upgraded.
          </p>
        </div>

        {/* Steps */}
        <div className="relative">
          {/* Connector line */}
          <div className="hidden md:block absolute left-[27px] top-10 bottom-10 w-px bg-gradient-to-b from-blue-500/40 via-indigo-500/20 to-transparent" />

          <div className="space-y-10">
            {steps.map(step => (
              <div key={step.n} className="flex gap-6 items-start">
                {/* Number */}
                <div className="flex-shrink-0 w-14 h-14 rounded-full glass-card flex items-center justify-center relative z-10">
                  <span className="font-mono font-bold text-[13px] text-blue-400">{step.n}</span>
                </div>

                {/* Content */}
                <div className="flex-1 pt-2">
                  <h3 className="font-display font-semibold text-xl text-white mb-2">
                    {step.hotkey
                      ? <>Hold <span className="kbd">⌘⇧</span>, tap <span className="kbd">V</span> to cycle.</>
                      : step.title
                    }
                  </h3>
                  <p className="text-slate-400 text-[15px] leading-relaxed mb-2">
                    {step.body}
                  </p>
                  <span className="text-[11px] font-mono text-slate-600 flex items-center gap-1.5">
                    <span className="w-1 h-1 rounded-full bg-slate-600 inline-block" />
                    {step.detail}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Extra features */}
        <div className="mt-16 grid sm:grid-cols-2 gap-4">
          {extras.map(e => (
            <div key={e.title} className="glass-card rounded-2xl p-6">
              <div className="text-2xl mb-3">{e.emoji}</div>
              <h4 className="font-display font-semibold text-white mb-2">{e.title}</h4>
              <p className="text-[14px] text-slate-400 leading-relaxed">{e.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
