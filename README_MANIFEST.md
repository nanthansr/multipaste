Repo context manifest

This repository includes a small utility to generate a repo-local context manifest
that agents can read before scanning files.

Usage:

```bash
python3 tools/gen_manifest.py
```

Output: `REPO_CONTEXT.md` at the repo root.

Design notes:
- Minimal, dependency-free script. Extensible to add hashes, embeddings, or YAML frontmatter.
- Intended as a first iteration: we can add incremental watches, git hooks, or a small service later.
# Repo-local manifest for agent context

This repo contains a small manifest generator that creates `repo_context_manifest.json`.

Usage:

```bash
python3 tools/generate_manifest.py
```

The manifest contains per-file previews, modification times, sizes, and SHA256 hashes. Agents can read `repo_context_manifest.json` first to get an overview and only fetch full files when necessary.
