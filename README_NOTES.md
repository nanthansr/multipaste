# Repo context notes

This folder `repo_context_notes/` contains a generated markdown note for each indexed file. Each note has YAML frontmatter with file metadata and a short preview.

Usage:

```bash
python3 tools/generate_notes.py
```

Agents should read `repo_context_manifest.json` first, then consult `repo_context_notes/` for a human-friendly, markdown-backed summary of files.
