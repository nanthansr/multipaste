import React, { useState } from 'react';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from '../config';

export default function FeedbackForm() {
  const [msg, setMsg] = useState('');
  const [status, setStatus] = useState<'idle' | 'sending' | 'done'>('idle');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!msg.trim()) return;
    setStatus('sending');
    try {
      await fetch(`${SUPABASE_URL}/rest/v1/feedback`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({ message: msg.trim(), device_id: 'web' }),
      });
    } catch (_) {}
    setMsg('');
    setStatus('done');
    setTimeout(() => setStatus('idle'), 4000);
  };

  return (
    <section className="relative z-10 py-16 px-5 border-t border-white/5">
      <div className="max-w-md mx-auto text-center">
        <h3 className="font-display font-semibold text-lg text-white mb-2">
          Got thoughts?
        </h3>
        <p className="text-[13px] text-slate-500 mb-6">
          Feature requests, bug reports, or a kind word. I read everything.
        </p>

        <form onSubmit={handleSubmit} className="flex flex-col gap-3">
          <textarea
            value={msg}
            onChange={e => setMsg(e.target.value)}
            placeholder="Your feedback..."
            rows={3}
            className="w-full px-4 py-3 rounded-xl bg-white/4 border border-white/8 text-[13px] text-slate-200 placeholder:text-slate-600 focus:outline-none focus:border-blue-500/40 focus:bg-white/6 transition-all resize-none font-mono"
          />
          <button
            type="submit"
            disabled={status === 'sending' || !msg.trim()}
            className="px-5 py-2.5 bg-white/8 hover:bg-white/12 border border-white/10 hover:border-white/18 text-[13px] font-semibold text-slate-200 rounded-xl transition-all disabled:opacity-40 disabled:cursor-not-allowed"
          >
            {status === 'sending' ? 'Sending...' : status === 'done' ? 'Sent — thank you!' : 'Send feedback'}
          </button>
        </form>
      </div>
    </section>
  );
}
