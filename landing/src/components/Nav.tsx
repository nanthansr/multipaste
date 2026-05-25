import React, { useState, useEffect } from 'react';
import { GUMROAD_URL, PRICE } from '../config';

export default function Nav() {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 16);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const links = [
    { label: 'Features', href: '#features' },
    { label: 'How it works', href: '#how-it-works' },
    { label: 'Pricing', href: '#pricing' },
  ];

  return (
    <nav
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-200 ${
        scrolled ? 'glass-nav' : 'bg-transparent'
      }`}
    >
      <div className="max-w-6xl mx-auto px-5 sm:px-8 py-3.5 flex items-center justify-between">
        {/* Logo */}
        <a href="/" className="flex items-center gap-2.5 select-none group">
          <div className="w-7 h-7 rounded-[8px] bg-gradient-to-br from-blue-500 via-indigo-500 to-violet-600 flex items-center justify-center shadow-sm shadow-blue-500/20 group-hover:shadow-blue-500/30 transition-shadow">
            <span className="text-white font-display font-bold text-sm leading-none">M</span>
          </div>
          <span className="font-display font-bold text-[15px] tracking-tight text-slate-100">
            Multipaste
          </span>
          <span className="hidden sm:inline text-[10px] font-mono font-semibold px-2 py-0.5 rounded-full bg-white/8 border border-white/10 text-slate-400 leading-none">
            v1.0
          </span>
        </a>

        {/* Desktop links */}
        <div className="hidden md:flex items-center gap-1">
          {links.map(l => (
            <a
              key={l.href}
              href={l.href}
              className="px-3.5 py-1.5 text-[13px] font-medium text-slate-400 hover:text-slate-100 rounded-lg hover:bg-white/5 transition-all"
            >
              {l.label}
            </a>
          ))}
        </div>

        {/* CTA */}
        <div className="flex items-center gap-3">
          <a
            href={GUMROAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="hidden sm:flex items-center gap-1.5 px-4 py-1.5 bg-blue-600 hover:bg-blue-500 active:scale-95 text-white text-[13px] font-semibold rounded-full transition-all shadow-sm shadow-blue-600/30"
          >
            Buy — {PRICE}
          </a>

          {/* Mobile hamburger */}
          <button
            onClick={() => setMenuOpen(o => !o)}
            className="md:hidden p-2 rounded-lg hover:bg-white/8 text-slate-400 hover:text-white transition-all"
            aria-label="Toggle menu"
          >
            <div className="w-4.5 flex flex-col gap-1">
              <span className={`block h-px bg-current transition-all ${menuOpen ? 'rotate-45 translate-y-1.5' : ''}`} />
              <span className={`block h-px bg-current transition-all ${menuOpen ? 'opacity-0' : ''}`} />
              <span className={`block h-px bg-current transition-all ${menuOpen ? '-rotate-45 -translate-y-1.5' : ''}`} />
            </div>
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {menuOpen && (
        <div className="md:hidden glass-nav border-t border-white/7 px-5 pb-4 pt-2 flex flex-col gap-1">
          {links.map(l => (
            <a
              key={l.href}
              href={l.href}
              onClick={() => setMenuOpen(false)}
              className="px-3 py-2 text-[13px] font-medium text-slate-300 hover:text-white rounded-lg hover:bg-white/5 transition-all"
            >
              {l.label}
            </a>
          ))}
          <a
            href={GUMROAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="mt-2 flex items-center justify-center gap-1.5 px-4 py-2 bg-blue-600 text-white text-[13px] font-semibold rounded-full transition-all"
          >
            Buy — {PRICE}
          </a>
        </div>
      )}
    </nav>
  );
}
