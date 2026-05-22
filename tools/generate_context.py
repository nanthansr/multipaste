#!/usr/bin/env python3
"""
generate_context.py

Scans the repository and writes a compact agent-facing context into `.context/`.

Usage:
  ./tools/generate_context.py         # incremental update (default)
  ./tools/generate_context.py --all   # re-scan all files

Outputs:
  .context/manifest.json   - JSON manifest with per-file metadata and hashes
  .context/summaries/*.md  - short human-readable summaries per file

This is repo-local and intended to be fast and incremental so agents can
read the small manifest instead of reloading the whole tree.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any

ROOT = Path(__file__).resolve().parents[1]
CTX_DIR = ROOT / ".context"
SUMMARIES_DIR = CTX_DIR / "summaries"
MANIFEST_PATH = CTX_DIR / "manifest.json"

SOURCE_EXTS = {"swift", "md", "txt", "py", "sh"}


def sha256_text(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def compute_file_hash(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            chunk = f.read(8192)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def extract_summary_text(text: str, max_chars: int = 600) -> str:
    # prefer top comment block
    comment_block = []
    for line in text.splitlines():
        if line.strip().startswith("//") or line.strip().startswith("/*") or line.strip().startswith("# "):
            comment_block.append(line.strip().lstrip("/ ").lstrip("# "))
        elif comment_block:
            break
    if comment_block:
        s = " ".join(comment_block)
        return s[:max_chars]

    # fallback: first non-empty paragraph
    for para in re.split(r"\n\s*\n", text):
        clean = para.strip()
        if clean:
            return clean[:max_chars]
    return ""


def discover_files(root: Path) -> list[Path]:
    files = []
    for p in root.rglob("*"):
        if p.is_file():
            if p.suffix.lstrip(".") in SOURCE_EXTS:
                # skip .context
                if ".context" in p.parts:
                    continue
                files.append(p)
    return sorted(files)


def summarize_swift_symbols(text: str) -> list[str]:
    # simple regex for top-level types and funcs
    pattern = re.compile(r"^(?:public\s+|private\s+|internal\s+)?(class|struct|enum|protocol|func|actor)\s+([A-Za-z0-9_]+)", re.MULTILINE)
    return [f"{m.group(1)} {m.group(2)}" for m in pattern.finditer(text)]


def load_manifest() -> Dict[str, Any]:
    if MANIFEST_PATH.exists():
        try:
            return json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def save_manifest(obj: Dict[str, Any]) -> None:
    CTX_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(obj, indent=2, ensure_ascii=False), encoding="utf-8")


def write_summary(path: Path, summary: str) -> None:
    SUMMARIES_DIR.mkdir(parents=True, exist_ok=True)
    rel = path.relative_to(ROOT)
    out = SUMMARIES_DIR / (str(rel).replace(os.sep, "__") + ".md")
    content = f"# Summary for {rel}\n\n{summary}\n"
    out.write_text(content, encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true", help="recompute everything")
    args = parser.parse_args(argv)

    manifest = load_manifest()
    files = discover_files(ROOT)

    updated = 0
    existing_files = manifest.get("files", {}) if manifest else {}

    now = datetime.now(timezone.utc).isoformat()
    new_manifest: Dict[str, Any] = {
        "version": 1,
        "generated_at": now,
        "repo": str(ROOT.name),
        "files": {},
    }

    for p in files:
        rel = str(p.relative_to(ROOT))
        h = compute_file_hash(p)
        info = existing_files.get(rel, {})
        if args.all or info.get("hash") != h:
            text = p.read_text(encoding="utf-8", errors="ignore")
            summary_text = extract_summary_text(text)
            symbols = []
            if p.suffix == ".swift":
                symbols = summarize_swift_symbols(text)

            # write per-file summary for agents and humans
            write_summary(p, summary_text or ("Symbols: " + ", ".join(symbols) if symbols else "(no summary)"))

            file_meta = {
                "path": rel,
                "hash": h,
                "lines": len(text.splitlines()),
                "last_modified": datetime.fromtimestamp(p.stat().st_mtime, tz=timezone.utc).isoformat(),
                "summary": summary_text,
                "symbols": symbols,
            }
            new_manifest["files"][rel] = file_meta
            updated += 1
        else:
            # reuse existing meta
            new_manifest["files"][rel] = info

    save_manifest(new_manifest)
    print(f"Scanned {len(files)} files, updated {updated} entries, manifest -> {MANIFEST_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
