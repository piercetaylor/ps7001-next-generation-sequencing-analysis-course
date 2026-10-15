#!/usr/bin/env python3
"""Check that relative links and images resolve.

Checks:
  1. Every relative link / image in *.md files and in the markdown cells of
     *.ipynb notebooks points to an existing file or directory (anchors and
     query strings are ignored; external URLs, mailto: and attachment: links
     are skipped).
  2. Every file listed in _toc.yml exists (with or without an extension).

Usage:  python tools/check_links.py [REPO_ROOT]
Exit status is 1 if anything is broken.
"""
import json
import os
import re
import sys
from urllib.parse import unquote

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..'))
SKIP_DIRS = {'.git', '_build', '.venv', 'node_modules', '.ipynb_checkpoints', '.jupyter_cache'}
DATA_KEEP = {'examples'}   # other data/ subfolders are downloaded, git-ignored data

MD_LINK = re.compile(r'!?\[(?:[^\[\]]|\[[^\]]*\])*\]\(\s*<?([^)\s>]+)>?(?:\s+"[^"]*")?\s*\)')
HTML_SRC = re.compile(r'<(?:img|a|source|video)\b[^>]*?(?:src|href)\s*=\s*["\']([^"\']+)["\']', re.I)
REF_DEF = re.compile(r'^\s*\[[^\]]+\]:\s*(\S+)', re.M)
FENCE = re.compile(r'(^|\n)(```|~~~).*?\n\2', re.S)
INLINE_CODE = re.compile(r'`[^`\n]*`')


def is_external(target):
    return bool(re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:', target)) or target.startswith('//')


def strip_code(text):
    # keep MyST directive fences such as ```{note} (they contain prose and links)
    def repl(m):
        block = m.group(0)
        return block if re.match(r'\s*(```|~~~)\{', block) else '\n'
    text = FENCE.sub(repl, text)
    return INLINE_CODE.sub('', text)


def targets(text):
    text = strip_code(text)
    for rx in (MD_LINK, HTML_SRC, REF_DEF):
        for m in rx.finditer(text):
            yield m.group(1)


def check_text(text, base_dir, where, errors):
    for t in targets(text):
        if not t or t.startswith('#') or is_external(t) or t.startswith('attachment:'):
            continue
        path = unquote(t.split('#', 1)[0].split('?', 1)[0])
        if not path:
            continue
        full = os.path.normpath(os.path.join(ROOT, path.lstrip('/')) if path.startswith('/')
                                else os.path.join(base_dir, path))
        if not os.path.exists(full):
            errors.append(f'{where}: broken link -> {t}')
        elif not full.startswith(ROOT):
            errors.append(f'{where}: link leaves the repository -> {t}')


def toc_files(toc_path):
    files = []
    for line in open(toc_path, encoding='utf-8'):
        m = re.match(r'\s*-?\s*(?:root|file)\s*:\s*(\S+)', line)
        if m:
            files.append(m.group(1))
    return files


def main():
    errors, n_md, n_nb, n_links = [], 0, 0, 0
    for dirpath, dirnames, filenames in os.walk(ROOT):
        rel_dir = os.path.relpath(dirpath, ROOT)
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS
                       and not (rel_dir == '.' and d.startswith('.') and d != '.github')
                       and not (rel_dir == 'data' and d not in DATA_KEEP)]
        for fn in filenames:
            p = os.path.join(dirpath, fn)
            rel = os.path.relpath(p, ROOT)
            if fn.endswith('.md'):
                n_md += 1
                text = open(p, encoding='utf-8').read()
                n_links += sum(1 for _ in targets(text))
                check_text(text, dirpath, rel, errors)
            elif fn.endswith('.ipynb'):
                n_nb += 1
                nb = json.load(open(p, encoding='utf-8'))
                for i, cell in enumerate(nb.get('cells', [])):
                    if cell.get('cell_type') != 'markdown':
                        continue
                    src = cell['source'] if isinstance(cell['source'], str) else ''.join(cell['source'])
                    n_links += sum(1 for _ in targets(src))
                    check_text(src, dirpath, f'{rel} [cell {i}]', errors)
                    for name in re.findall(r'attachment:([^)\s]+)', src):
                        if name not in cell.get('attachments', {}):
                            errors.append(f'{rel} [cell {i}]: missing attachment {name}')
    toc = os.path.join(ROOT, '_toc.yml')
    n_toc = 0
    if os.path.exists(toc):
        for f in toc_files(toc):
            n_toc += 1
            base = os.path.join(ROOT, f)
            if not any(os.path.exists(base + ext) for ext in ('', '.md', '.ipynb')):
                errors.append(f'_toc.yml: missing file -> {f}')
    else:
        errors.append('_toc.yml not found')
    print(f'checked {n_md} markdown files, {n_nb} notebooks, {n_links} links, {n_toc} _toc.yml entries')
    if errors:
        print(f'{len(errors)} problem(s):')
        for e in errors:
            print('  ' + e)
        return 1
    print('all relative links, images and _toc.yml entries resolve')
    return 0


if __name__ == '__main__':
    sys.exit(main())
