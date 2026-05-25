import React from 'react';
import { GUMROAD_URL, PRICE, MACOS_REQUIREMENT } from '../config';

export default function DownloadCTA() {
  return (
    <section className="relative z-10 py-24 px-5 border-t border-white/5 overflow-hidden">
      {/* Ambient glow */}
      <div className="glow-blue absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[560px] h-[320px] pointer-events-none opacity-70" />

      <div className="relative max-w-2xl mx-auto text-center">
        <h2 className="font-display font-bold text-3xl sm:text-4xl lg:text-5xl text-white mb-5">
          Ready to paste like a surgeon?
        </h2>
        <p className="text-slate-400 text-base mb-10 max-w-lg mx-auto">
          Join the clipboard interaction-layer you didn't know you were missing. One-time purchase, on your Mac, forever.
        </p>

        <a
          href={GUMROAD_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center justify-center gap-2.5 px-8 py-4 bg-blue-600 hover:bg-blue-500 active:scale-[0.97] text-white text-[16px] font-semibold rounded-full transition-all shadow-xl shadow-blue-600/25 hover:shadow-blue-500/35"
        >
          Buy Multipaste — {PRICE}
        </a>

        <div className="mt-6 flex flex-wrap items-center justify-center gap-4 text-[12px] font-mono text-slate-600">
          <span>{MACOS_REQUIREMENT}</span>
          <span>·</span>
          <span>Direct download</span>
          <span>·</span>
          <span>No subscription</span>
          <span>·</span>
          <span>Secure checkout via Gumroad</span>
        </div>
      </div>
    </section>
  );
}
