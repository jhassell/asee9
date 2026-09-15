#!/usr/bin/env python3
"""Check site/ before calling a public website done.

site/ is served publicly on port 8000 while the Codespace runs (see
site-public.sh), and bash publish-site.sh can put a copy of it on a permanent
public address. Both of those publish only the real files inside site/.

Every readable text file is scanned, whatever it is called: a key in .env,
config.yaml or a file with no extension is as public as one in index.html.
Files that look binary (images, PDFs, fonts) are skipped.

Fails (exit 1) on:
  - a key-like string or a secret's variable name
  - a symlink anywhere under site/ (only real files are served and published)
  - a local link or image that points at a missing file, or at a file outside
    site/ (it would work here and 404 on the published site)
  - no site/index.html

Warns (exit 0) on things a person should look at:
  - email addresses at a .edu domain
  - long digit runs that could be student ID numbers
  - 64-character hex strings (the shape of an older Netlify token)

It prints only file names and short labels, never the matched text, so its
output is safe to paste anywhere.

Usage: python3 .devcontainer/site-check.py [path/to/site]
"""
import pathlib
import re
import sys
from html.parser import HTMLParser

ROOT = pathlib.Path(__file__).resolve().parent.parent
# Only used to decide which files get their links parsed. Every other check
# runs on every readable text file, whatever its name.
HTML_SUFFIXES = (".html", ".htm")
READ_LIMIT = 4 * 1024 * 1024   # scan at most this much of one file
HEAD_BYTES = 8192              # this much decides text or binary

KEYLIKE = re.compile(
    r"(sk-or-[A-Za-z0-9-]{10,}"
    r"|sk-[A-Za-z0-9_-]{20,}"
    r"|github_pat_[A-Za-z0-9_]{10,}"
    r"|gh[pousr]_[A-Za-z0-9]{20,}"
    r"|nf[po]_[A-Za-z0-9]{20,}"
    r"|AKIA[0-9A-Z]{16}"
    r"|-----BEGIN [A-Z ]*PRIVATE KEY-----"
    r"|OPENROUTER_API_KEY|GITHUB_TOKEN|NETLIFY_AUTH_TOKEN)"
)
EDU_EMAIL = re.compile(r"\b[A-Za-z0-9._%+-]+@(?:[A-Za-z0-9-]+\.)+edu\b", re.IGNORECASE)
# 7 to 10 digits standing alone: the shape of most student ID numbers. Years,
# page numbers and prices are shorter; phone numbers with separators do not match.
ID_LIKE = re.compile(r"(?<![\d.,/-])\d{7,10}(?![\d.,/-])")
# Netlify also issued 64-character hex tokens. A SHA-256 checksum on a page has
# the same shape, so this warns instead of failing.
HEX64 = re.compile(r"(?<![0-9A-Za-z])[0-9a-f]{64}(?![0-9A-Za-z])")


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []

    def handle_starttag(self, tag, attrs):
        for k, v in attrs:
            if k in ("href", "src") and v:
                self.links.append(v)


def read_text(path):
    """The file's text, or None if it is binary or cannot be read."""
    try:
        with open(path, "rb") as fh:
            data = fh.read(READ_LIMIT)
    except OSError:
        return None
    head = data[:HEAD_BYTES]
    if b"\x00" in head:
        return None
    if head:
        odd = sum(1 for b in head if (b < 32 and b not in (8, 9, 10, 12, 13)) or b == 127)
        if odd / len(head) > 0.15:
            return None
    return data.decode("utf-8", "ignore")


def name_of(path, site):
    try:
        return path.relative_to(site.parent)
    except ValueError:
        return path


def check(site):
    problems, warnings = [], []
    if not site.is_dir():
        return None, problems, warnings
    site_real = site.resolve()
    files = []
    for p in sorted(site.rglob("*")):
        if p.is_symlink():
            # Neither the local server nor publish-site.sh follows one, so a
            # symlink is at best missing from the published site and at worst
            # a pointer at something private.
            problems.append(f"{name_of(p, site)}: is a symlink. site/ must hold real files.")
            continue
        if p.is_file():
            files.append(p)
    for f in files:
        raw = read_text(f)
        if raw is None:
            continue           # binary or unreadable: nothing to scan
        rel = name_of(f, site)
        if KEYLIKE.search(raw):
            problems.append(f"{rel}: contains something that looks like a key or token name")
        if f.suffix.lower() in HTML_SUFFIXES:
            parser = Links()
            parser.feed(raw)
            for link in parser.links:
                if re.match(r"^(https?:|mailto:|tel:|#|data:|javascript:|//)", link, re.IGNORECASE):
                    continue
                path = link.split("#")[0].split("?")[0]
                if not path:
                    continue
                target = (site / path.lstrip("/")) if path.startswith("/") else (f.parent / path)
                try:
                    real = target.resolve()
                except OSError:
                    real = None
                if real is None or (real != site_real and site_real not in real.parents):
                    problems.append(
                        f"{rel}: local link points outside site/, so it will be missing "
                        f"on the published site ({link[:60]})")
                elif not real.exists():
                    problems.append(f"{rel}: local link to a missing file ({link[:60]})")
        n = len(EDU_EMAIL.findall(raw))
        if n:
            warnings.append(f"{rel}: {n} .edu email address(es). Are they meant to be public?")
        n = len(ID_LIKE.findall(raw))
        if n:
            warnings.append(f"{rel}: {n} number(s) shaped like student IDs (7-10 digits). Check them.")
        n = len(HEX64.findall(raw))
        if n:
            warnings.append(f"{rel}: {n} 64-character hex string(s). A checksum is fine; an access token is not.")
    if not (site / "index.html").exists():
        problems.append("site/index.html is missing (the public URL shows the folder list)")
    return files, problems, warnings


def main():
    site = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / "site"
    files, problems, warnings = check(site)
    if files is None:
        print("No site/ folder yet.")
        return 0
    print(f"Checked {len(files)} file(s) in {site.name}/.")
    for w in warnings:
        print("  WARNING: " + w)
    if problems:
        print("NOT READY TO BE PUBLIC:")
        for p in problems:
            print("  - " + p)
        return 1
    print("OK: no key-like strings, no broken local links, index.html present.")
    if warnings:
        print("Look at the warnings above before sharing the link.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
