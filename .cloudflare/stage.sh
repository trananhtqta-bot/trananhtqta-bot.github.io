#!/usr/bin/env bash
# usage: stage.sh <path-prefix> <source-dir> <dist-dir>
# Copies tracked repo files into dist/<prefix>/ so URLs match the old GitHub Pages paths.
set -euo pipefail
PREFIX="$1"; SRC="$2"; DIST="$3"
rm -rf "$DIST"; mkdir -p "$DIST/$PREFIX"
git -C "$SRC" ls-files -z \
 | grep -zv -e '^\.git' -e '^\.cloudflare/' -e '^wrangler\.jsonc$' -e '^CNAME$' -e '^\.nojekyll$' -e '^\.gitignore$' -e '^\.assetsignore$' \
 | tar -C "$SRC" --null -T - -cf - | tar -C "$DIST/$PREFIX" -xf -
PAT="/$PREFIX/*"; [ "$PREFIX" = "." ] && PAT="/*"
printf '%s\n  Access-Control-Allow-Origin: *\n' "$PAT" > "$DIST/_headers"
[ -f "$DIST/404.html" ] || cp /dev/stdin "$DIST/404.html" <<'H'
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Góc Nhỏ Nuôi Cô Chủ</title><meta http-equiv="refresh" content="0;url=/"><script>location.replace('/');</script></head><body><p><a href="/">Góc Nhỏ Nuôi Cô Chủ</a></p></body></html>
H
echo "staged $(find "$DIST" -type f | wc -l) files, $(du -sh "$DIST" | cut -f1)"
