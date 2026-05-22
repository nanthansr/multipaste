#!/usr/bin/env python3
"""Generate a repo-local context manifest for agent consumption.

What it does:
- Walks the repo (current directory) and summarizes source files.
- Emits `REPO_CONTEXT.md` with per-file metadata (path, lines, last modified).
- Produces a small top-level summary for quick agent injection.

This is intentionally minimal and dependency-free.
"""
import os
import sys
from datetime import datetime

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "REPO_CONTEXT.md")

IGNORE = {".git", "build", "node_modules", "__pycache__"}
EXT_WHITELIST = {"swift", "md", "py", "txt", "sh"}


def file_summary(path):
    try:
        st = os.stat(path)
        mtime = datetime.fromtimestamp(st.st_mtime).isoformat()
        with open(path, "r", errors="ignore") as f:
            lines = f.readlines()
        first = "".join(lines[:5]).strip().replace("\n", " ")
        return {
            "path": os.path.relpath(path, ROOT),
            "lines": len(lines),
            "mtime": mtime,
            "preview": first,
        }
    except Exception as e:
        return {"path": os.path.relpath(path, ROOT), "error": str(e)}


def walk_repo():
    files = []
    for dirpath, dirnames, filenames in os.walk(ROOT):
        # mutate dirnames in-place to skip ignored dirs
        dirnames[:] = [d for d in dirnames if d not in IGNORE]
        for fn in filenames:
            if fn.startswith('.'):
                continue
            path = os.path.join(dirpath, fn)
            ext = fn.split('.')[-1].lower() if '.' in fn else ''
            if ext and ext not in EXT_WHITELIST:
                continue
            files.append(file_summary(path))
    return files


def render(manifest):
    total_files = len(manifest)
    lines = ["# Repo Context Manifest", "", f"Generated: {datetime.utcnow().isoformat()}Z", "", "## Summary", "", f"- Files indexed: {total_files}", "", "## Files", ""]
    for f in sorted(manifest, key=lambda x: x.get("path")):
        lines.append(f"### {f.get('path')}")
        if 'error' in f:
            lines.append(f"- error: {f['error']}")
            lines.append("")
            continue
        lines.append(f"- lines: {f.get('lines')}")
        lines.append(f"- mtime: {f.get('mtime')}")
        preview = f.get('preview') or ""
        if preview:
            lines.append(f"- preview: {preview}")
        lines.append("")
    return "\n".join(lines)


def main():
    manifest = walk_repo()
    out = render(manifest)
    with open(OUT, "w") as f:
        f.write(out)
    print(f"Wrote {OUT} with {len(manifest)} entries")


if __name__ == '__main__':
    main()
