# Repo-local context manifest (design)

Purpose
- Provide a tiny, versioned, repo-local "second brain" that coding agents can read first to avoid re-scanning a whole repo each run.

What lives here
- `.context/manifest.json` — compact JSON manifest listing files, stable metadata, content hashes, and short summaries.
- `.context/summaries/*` — per-file Markdown summaries meant for quick human and agent consumption.

Design principles
- Repo-local: keeps context close to the source of truth and versionable in git when desired.
- Incremental: generator updates only files that changed (by hash) to stay fast.
- Human readable: summaries are Markdown so you can inspect and edit when needed.
- Guarded: do not include secrets or large blobs. The generator excludes typical binary/docs.

Manifest schema (v1)

{
  "version": 1,
  "generated_at": "ISO8601",
  "repo": "multipaste",
  "files": {
    "path/to/file.swift": {
      "path": "path/to/file.swift",
      "hash": "sha256",
      "lines": 120,
      "last_modified": "ISO8601",
      "summary": "short text",
      "symbols": ["class Foo", "func bar"]
    }
  }
}

How agents should use it
- Read `.context/manifest.json` first.
- Inject top-level repo metadata and the most-recent summaries relevant to the task.
- When deeper detail is required, read the specific file from the repo (not from the manifest).

How to refresh
- Run `./tools/generate_context.py` from the repo root. Use `--all` to force a full rebuild.

Next steps
- Optionally: add a git hook to regenerate on commit or a small watcher for local development.
