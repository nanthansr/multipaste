---
file: README_MANIFEST.md
size: 386
mtime: 2026-05-21T11:52:36.573868Z
sha256: 2bc940f6c550b2e7571e051da5b4ad123db309238c40825d5620e6950ca4e1b1
---

# README_MANIFEST.md

**Summary:** # Repo-local manifest for agent context

## Preview

```
# Repo-local manifest for agent context

This repo contains a small manifest generator that creates `repo_context_manifest.json`.

Usage:

```bash
python3 tools/generate_manifest.py
```

The manifest contains per-file previews, modification times, sizes, and SHA256 hashes. Agents can read `repo_context_manifest.json` first to get an overview and only fetch full files when necessary.
```
