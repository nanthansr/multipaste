#!/usr/bin/env python3
import os
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'repo_context_manifest.json'
NOTES_DIR = ROOT / 'repo_context_notes'

SAFE_RE = re.compile(r'[^A-Za-z0-9_.-]')


def slug_path(p):
    return SAFE_RE.sub('_', p.replace(os.sep, '__'))


def write_note(entry):
    path = entry['path']
    slug = slug_path(path)
    out = NOTES_DIR / f"{slug}.md"
    front = {
        'file': path,
        'size': entry.get('size'),
        'mtime': entry.get('mtime'),
        'sha256': entry.get('sha256')
    }
    preview = entry.get('preview','').strip()
    # Short auto-summary: first non-empty line of preview
    summary = ''
    for line in preview.splitlines():
        s = line.strip()
        if s:
            summary = s
            break
    if len(summary) > 240:
        summary = summary[:237] + '...'

    NOTES_DIR.mkdir(parents=True, exist_ok=True)
    with open(out, 'w') as f:
        f.write('---\n')
        for k,v in front.items():
            f.write(f"{k}: {v}\n")
        f.write('---\n\n')
        f.write(f"# {path}\n\n")
        f.write(f"**Summary:** {summary or '(none)'}\n\n")
        f.write('## Preview\n\n')
        f.write('```\n')
        f.write(preview[:5000])
        f.write('\n```\n')


if __name__ == '__main__':
    if not MANIFEST.exists():
        print('manifest not found, run tools/generate_manifest.py first')
        raise SystemExit(1)
    with open(MANIFEST) as f:
        m = json.load(f)
    for e in m.get('files', []):
        try:
            write_note(e)
        except Exception as ex:
            print('failed for', e.get('path'), ex)
    print('wrote notes to', NOTES_DIR)
