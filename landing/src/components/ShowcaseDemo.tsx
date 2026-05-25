import React, { useState } from 'react';
import { Search, Copy, Check } from 'lucide-react';
import { DEMO_CLIPS } from '../data';
import { ClipItem } from '../types';

function ClipRow({ clip, index, onCopy, copied }: { clip: ClipItem; index: number; onCopy: (id: string) => void; copied: boolean }) {
  const typeColors: Record<string, string> = {
    code:  'text-emerald-400 bg-emerald-500/10 border-emerald-500/20',
    text:  'text-blue-400 bg-blue-500/10 border-blue-500/20',
    color: 'text-violet-400 bg-violet-500/10 border-violet-500/20',
    link:  'text-amber-400 bg-amber-500/10 border-amber-500/20',
    image: 'text-pink-400 bg-pink-500/10 border-pink-500/20',
  };
  const typeLabel: Record<string, string> = {
    code: 'CODE', text: 'TEXT', color: 'COLOR', link: 'LINK', image: 'IMG',
  };

  return (
    <div className="group flex items-center gap-3 p-3 rounded-xl border border-white/5 hover:border-white/12 bg-white/3 hover:bg-white/6 transition-all cursor-default">
      {/* Index badge */}
      <span className="w-7 h-7 flex items-center justify-center rounded-md text-[10px] font-mono font-bold bg-white/8 border border-white/10 text-slate-300 shrink-0">
        {index + 1}
      </span>

      {/* Type badge */}
      <span className={`text-[9px] font-mono font-bold px-1.5 py-0.5 rounded border shrink-0 ${typeColors[clip.type]}`}>
        {typeLabel[clip.type]}
      </span>

      {/* Color swatch if applicable */}
      {clip.colorHex && (
        <span
          className="w-4 h-4 rounded-full border border-white/20 shrink-0"
          style={{ background: clip.colorHex }}
        />
      )}

      {/* Content */}
      <div className="flex-1 min-w-0">
        <p className="text-[11px] font-mono text-slate-200 truncate leading-tight">
          {clip.content.split('\n')[0]}
        </p>
        {clip.title && (
          <p className="text-[10px] text-slate-500 mt-0.5 truncate">{clip.title} · {clip.sourceApp} · {clip.timeAgo} ago</p>
        )}
      </div>

      {/* Hotkey + copy */}
      <div className="flex items-center gap-1.5 shrink-0 opacity-0 group-hover:opacity-100 transition-opacity">
        <span className="kbd text-[9px]">⌥{index + 1}</span>
        <button
          onClick={() => onCopy(clip.id)}
          className="p-1.5 rounded-lg hover:bg-white/10 text-slate-400 hover:text-white transition-all"
          aria-label="Copy"
        >
          {copied ? <Check className="w-3 h-3 text-emerald-400" /> : <Copy className="w-3 h-3" />}
        </button>
      </div>
    </div>
  );
}

export default function ShowcaseDemo() {
  const [search, setSearch] = useState('');
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const filtered = DEMO_CLIPS.filter(c =>
    c.content.toLowerCase().includes(search.toLowerCase()) ||
    c.title?.toLowerCase().includes(search.toLowerCase()) ||
    c.sourceApp.toLowerCase().includes(search.toLowerCase())
  );

  const handleCopy = (id: string) => {
    const clip = DEMO_CLIPS.find(c => c.id === id);
    if (clip) navigator.clipboard.writeText(clip.content).catch(() => {});
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 1500);
  };

  return (
    <section className="relative z-10 px-5 pb-20">
      <div className="max-w-3xl mx-auto">

        {/* macOS window chrome */}
        <div className="glass-panel rounded-2xl overflow-hidden">
          {/* Title bar */}
          <div className="flex items-center justify-between px-4 py-3 border-b border-white/8">
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full bg-[#ff5f56]" />
              <span className="w-3 h-3 rounded-full bg-[#ffbd2e]" />
              <span className="w-3 h-3 rounded-full bg-[#27c93f]" />
              <span className="ml-3 text-[11px] font-mono font-semibold text-slate-400">
                Multipaste — recent clips
              </span>
            </div>
            {/* Search */}
            <div className="relative w-52">
              <Search className="w-3 h-3 absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-500" />
              <input
                type="text"
                placeholder="Fuzzy search..."
                value={search}
                onChange={e => setSearch(e.target.value)}
                className="w-full pl-7 pr-3 py-1.5 rounded-lg text-[11px] font-mono bg-black/30 border border-white/10 text-slate-300 placeholder:text-slate-600 focus:outline-none focus:border-blue-500/50 transition-colors"
              />
            </div>
          </div>

          {/* Clip list */}
          <div className="p-3 space-y-1.5 max-h-[340px] overflow-y-auto">
            {filtered.length > 0
              ? filtered.map((clip, i) => (
                  <ClipRow
                    key={clip.id}
                    clip={clip}
                    index={i}
                    onCopy={handleCopy}
                    copied={copiedId === clip.id}
                  />
                ))
              : (
                <div className="text-center py-10 text-xs font-mono text-slate-600">
                  No clips match "{search}"
                </div>
              )
            }
          </div>

          {/* Status bar */}
          <div className="px-4 py-2 border-t border-white/6 flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
            <span className="text-[10px] font-mono text-slate-500">
              {filtered.length} clips · Hold <span className="text-slate-400">⌘⇧</span> then tap <span className="text-slate-400">V</span> to cycle
            </span>
          </div>
        </div>

        <p className="text-center text-xs text-slate-600 mt-4 font-mono">
          Interactive demo — this runs live in your browser
        </p>
      </div>
    </section>
  );
}
