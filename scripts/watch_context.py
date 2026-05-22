#!/usr/bin/env python3
"""
Simple polling watcher that regenerates the repo context manifest when files change.

Usage: python3 scripts/watch_context.py [interval_seconds]
"""
from __future__ import annotations
import time
import sys
from pathlib import Path
from datetime import datetime
import subprocess

ROOT = Path(__file__).resolve().parent.parent
INTERVAL = float(sys.argv[1]) if len(sys.argv) > 1 else 2.0

def snapshot_mtimes(root: Path):
    mt = {}
    for p in root.rglob('*'):
        try:
            if p.is_file():
                mt[str(p.relative_to(root))] = p.stat().st_mtime
        except Exception:
            continue
    return mt

def main():
    prev = snapshot_mtimes(ROOT)
    print(f"Watching {ROOT} for changes (interval={INTERVAL}s). Ctrl-C to stop.")
    try:
        while True:
            time.sleep(INTERVAL)
            curr = snapshot_mtimes(ROOT)
            if curr != prev:
                print(f"Change detected at {datetime.utcnow().isoformat()} — regenerating manifest.")
                subprocess.run([sys.executable, str(ROOT / 'scripts' / 'generate_context.py')])
                prev = curr
    except KeyboardInterrupt:
        print("Watcher stopped")

if __name__ == '__main__':
    main()
