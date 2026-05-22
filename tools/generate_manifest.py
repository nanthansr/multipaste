#!/usr/bin/env python3
import os
import sys
import json
import hashlib
from datetime import datetime

ROOT = os.path.dirname(os.path.dirname(__file__))
SRC = os.path.join(ROOT, 'Sources')
MANIFEST_PATH = os.path.join(ROOT, 'repo_context_manifest.json')

EXTS = ['.swift', '.md', '.swiftpm', '.txt', '.sh']


def file_hash(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        while True:
            chunk = f.read(8192)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def summarize_file(path):
    stat = os.stat(path)
    ch = file_hash(path)
    with open(path, 'r', errors='replace') as f:
        lines = f.readlines()
    head = ''.join(lines[:200])
    return {
        'path': os.path.relpath(path, ROOT),
        'size': stat.st_size,
        'mtime': datetime.utcfromtimestamp(stat.st_mtime).isoformat() + 'Z',
        'sha256': ch,
        'preview': head[:2000]
    }


def build_manifest(root):
    files = []
    for dirpath, dirnames, filenames in os.walk(root):
        # skip hidden directories
        if any(p.startswith('.') for p in dirpath.split(os.sep)):
            continue
        for fn in filenames:
            if os.path.splitext(fn)[1] in EXTS:
                path = os.path.join(dirpath, fn)
                try:
                    files.append(summarize_file(path))
                except Exception as e:
                    print('skip', path, e)
    manifest = {
        'generated_at': datetime.utcnow().isoformat() + 'Z',
        'repo': os.path.basename(ROOT),
        'files': files
    }
    return manifest


if __name__ == '__main__':
    m = build_manifest(ROOT)
    with open(MANIFEST_PATH, 'w') as f:
        json.dump(m, f, indent=2)
    print('wrote', MANIFEST_PATH)
