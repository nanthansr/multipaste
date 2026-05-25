import React from 'react';

export default function Footer() {
  return (
    <footer className="relative z-10 py-10 px-5 border-t border-white/5">
      <div className="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-[12px] font-mono text-slate-600">
        <div className="flex items-center gap-1.5">
          <span className="font-display font-semibold text-slate-500">Multipaste</span>
          <span>·</span>
          <span>© 2026</span>
          <span>·</span>
          <span>Built with Claude Code</span>
        </div>

        <div className="flex items-center gap-4">
          <a href="/privacy" className="hover:text-slate-400 transition-colors">
            Privacy Policy
          </a>
          <span>·</span>
          <span>macOS 13+</span>
          <span>·</span>
          <span className="text-slate-700">Not affiliated with Apple Inc.</span>
        </div>
      </div>
    </footer>
  );
}
