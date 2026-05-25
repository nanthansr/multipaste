import React from 'react';

export default function FounderNote() {
  return (
    <section className="relative z-10 py-24 px-5 border-t border-white/5">
      <div className="max-w-2xl mx-auto">

        <div className="text-center mb-10">
          <span className="text-[11px] font-mono font-semibold uppercase tracking-widest text-slate-600">
            Why I built this
          </span>
        </div>

        <div className="glass-card rounded-2xl p-8 sm:p-10">
          <div className="prose prose-invert max-w-none">
            <p className="text-[15px] sm:text-base text-slate-300 leading-[1.75] mb-5">
              My actual workflow before Multipaste: copy API key → switch tab → paste → wrong field.
              Copy config value → switch tab → wrong tab. <span className="kbd">⌘Z</span>. Repeat.
              By the time I'd pasted the third thing I'd already lost two of the first two.
            </p>

            <p className="text-[15px] sm:text-base text-slate-300 leading-[1.75] mb-5">
              The clipboard managers I tried all solved the wrong problem. They're archives — great
              for retrieving something from last Tuesday, useless for the code you copied 8 seconds
              ago. And then macOS 26 shipped clipboard history built into Spotlight, which made
              the "clipboard history app" category officially free.
            </p>

            <p className="text-[15px] sm:text-base text-slate-300 leading-[1.75] mb-5">
              Multipaste is the opposite. It doesn't try to remember everything. It gives you
              instant, cursor-positioned access to what you're <em>copying right now</em> —
              without breaking the flow of what you're doing. Hold two keys, tap one more,
              release. The whole thing takes less than a second.
            </p>

            <p className="text-[15px] sm:text-base text-slate-300 leading-[1.75]">
              12 weeks, a CGEventTap that took 3 days to get right, and a radial HUD I'm
              still proud of. Built entirely with Claude Code. The interaction layer macOS
              was always missing.
            </p>
          </div>

          {/* Attribution */}
          <div className="mt-8 pt-6 border-t border-white/8 flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-violet-600 flex items-center justify-center text-white font-display font-bold text-sm">
              N
            </div>
            <div>
              <p className="text-[13px] font-medium text-white">Nanthan</p>
              <p className="text-[11px] text-slate-500 font-mono">Builder · Multipaste</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
