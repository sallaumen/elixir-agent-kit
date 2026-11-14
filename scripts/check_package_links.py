#!/usr/bin/env python3
"""Check Markdown file destinations against the actual Hex archive, not the checkout."""
import io
import posixpath
import re
import sys
import tarfile
from urllib.parse import unquote, urlsplit


def check(archive):
    with tarfile.open(archive) as outer:
        with tarfile.open(fileobj=io.BytesIO(outer.extractfile("contents.tar.gz").read())) as inner:
            files = {entry.name for entry in inner if entry.isfile()}
            errors, checked = [], 0
            for source in sorted(name for name in files if name.endswith(".md")):
                text = inner.extractfile(source).read().decode()
                for target in re.findall(r'\]\(([^)]+)\)', text):
                    url = urlsplit(target)
                    if url.scheme or url.netloc or not url.path:
                        continue
                    checked += 1
                    path = posixpath.normpath(posixpath.join(posixpath.dirname(source), unquote(url.path)))
                    if path not in files:
                        errors.append(f"{source}: missing from archive: {target}")
    if errors:
        raise SystemExit("\n".join(errors))
    print(f"OK: {checked} local Markdown file references resolve inside {archive}.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python3 scripts/check_package_links.py PACKAGE.tar")
    check(sys.argv[1])
