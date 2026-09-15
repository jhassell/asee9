#!/usr/bin/env python3
"""Serve ONE folder on port 8000, and nothing outside it.

Started detached by site-public.sh. Python's own `python3 -m http.server
--directory site` is not used here: it strips ".." from the URL path but never
resolves symlinks, so a single link inside site/ (say `ln -s ~ site/home`)
would publish whatever it points at - including ~/.openclaw/openclaw.json,
which holds the OpenRouter key - on a port that site-public.sh makes public.

Every request is refused unless the real path of what it asks for is inside the
served folder. site-check.py also fails on a symlink under site/, so the two
paths (this server and publish-site.sh, which never zips a symlink) agree about
what the site contains.

Usage: python3 site-server.py <folder> [port]
"""
import http.server
import os
import sys

ROOT = os.path.realpath(sys.argv[1] if len(sys.argv) > 1 else "site")
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 8000


def inside(path):
    real = os.path.realpath(path)
    return real == ROOT or real.startswith(ROOT + os.sep)


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def send_head(self):
        # The one hook both GET and HEAD go through, and it runs before the
        # parent's directory redirect and folder listing.
        if not inside(self.translate_path(self.path)):
            self.send_error(404, "File not found")
            return None
        return super().send_head()

    def list_directory(self, path):
        if not inside(path):
            self.send_error(404, "File not found")
            return None
        return super().list_directory(path)


def main():
    if not os.path.isdir(ROOT):
        sys.stderr.write("site-server: no folder at %s\n" % ROOT)
        return 1
    server = http.server.ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    sys.stderr.write("site-server: serving %s on port %d\n" % (ROOT, PORT))
    sys.stderr.flush()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
