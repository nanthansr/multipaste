#!/usr/bin/env python3
"""
Generate a repo-local context manifest for AI agents.

Writes `.repo_context/manifest.json` and `.repo_context/manifest.md` with
per-file metadata (path, size, mtime, sha256, title, short summary).

Usage: python3 scripts/generate_context.py
"""
from __future__ import annotations
import hashlib
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / ".repo_context"
OUT_DIR.mkdir(exist_ok=True)

INCLUDE_EXT = {".swift", ".md", ".txt", ".py"}
INCLUDE_NAMES = {"Package.swift", "MULTIPASTE_PLAN.md", "README.md"}
EXCLUDE_DIRS = {".git", "build", "node_modules", ".vscode", ".repo_context", ".build"}

def estimate_language(p: Path) -> str:
    if p.name in ("Package.swift",):
        return "Swift Package"
    ext = p.suffix.lower()
    if ext == ".swift":
        return "Swift"
    if ext == ".md":
        return "Markdown"
    if ext == ".py":
        return "Python"
    return ext.lstrip('.') or "file"

def title_from_content(p: Path, text: str) -> str:
    if p.suffix.lower() == ".md":
        for line in text.splitlines():
            if line.strip().startswith('#'):
                return line.strip('# ').strip()
    # fallback: first comment or filename
    for line in text.splitlines():
        s = line.strip()
        if s.startswith('//') or s.startswith('#'):
            return s.lstrip('/# ').strip()[:80]
    return p.name

def short_summary(text: str, n: int = 240) -> str:
    s = text.strip().replace('\r\n', '\n')
    if not s:
        return ""
    # take first paragraph
    parts = [p.strip() for p in s.split('\n\n') if p.strip()]
    first = parts[0] if parts else s
    return (first[:n] + '...') if len(first) > n else first

def file_metadata(p: Path) -> Dict:
    try:
        raw = p.read_text(encoding='utf-8', errors='ignore')
    except Exception:
        raw = ''
    b = raw.encode('utf-8')
    sha = hashlib.sha256(b).hexdigest()
    mtime = datetime.fromtimestamp(p.stat().st_mtime).isoformat()
    return {
        "path": str(p.relative_to(ROOT)),
        "name": p.name,
        "language": estimate_language(p),
        "size_bytes": len(b),
        "sha256": sha,
        "mtime": mtime,
        "title": title_from_content(p, raw),
        "summary": short_summary(raw),
        "words": len(raw.split()),
    }

def should_include(p: Path) -> bool:
    if any(part in EXCLUDE_DIRS for part in p.parts):
        return False
    if p.is_dir():
        return False
    if p.name in INCLUDE_NAMES:
        return True
    if p.suffix.lower() in INCLUDE_EXT:
        return True
    return False

def discover_files() -> List[Path]:
    files: List[Path] = []
    for p in ROOT.rglob('*'):
        if should_include(p):
            files.append(p)
    return sorted(files)

def write_manifest(manifest: List[Dict]):
    j = OUT_DIR / 'manifest.json'
    m = OUT_DIR / 'manifest.md'
    j.write_text(json.dumps({"generated_at": datetime.utcnow().isoformat(), "files": manifest}, indent=2), encoding='utf-8')

    lines = ["# Repo context manifest", "", f"Generated: {datetime.utcnow().isoformat()} UTC", "", "| path | title | lang | size | mtime | summary |", "|---|---|---:|---:|---|---|"]
    for f in manifest:
        path = f['path']
        title = (f['title'] or '')[:60].replace('\n', ' ')
        lang = f['language']
        size = f['size_bytes']
        mtime = f['mtime']
        summary = (f['summary'] or '').replace('\n', ' ')[:140]
        lines.append(f"| {path} | {title} | {lang} | {size} | {mtime} | {summary} |")

    m.write_text('\n'.join(lines), encoding='utf-8')

def main() -> int:
    files = discover_files()
    manifest = []
    for p in files:
        manifest.append(file_metadata(p))

    write_manifest(manifest)
    print(f"Wrote manifest for {len(manifest)} files to {OUT_DIR}")
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
