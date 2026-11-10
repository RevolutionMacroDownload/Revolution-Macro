#!/usr/bin/env bash
# Mirrors revolutionmacro.com into ./revolution
set -euo pipefail
BASE="https://revolutionmacro.com"
OUT="revolution"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/126 Safari/537.36"

mkdir -p "$OUT" && cd "$OUT"

# 1. the page itself
curl -sSL -A "$UA" "$BASE/" -o index.html

# 2. every asset referenced in the HTML
grep -oE '(/assets/[^"'"'"']+\.(js|css)|/images/[^"'"'"']+\.(png|webp|svg|jpg|jpeg)|/videos/[^"'"'"']+\.mp4|/favicon\.ico)' index.html \
  | sed 's/&amp;/\&/g' | sort -u | while read -r p; do
      mkdir -p ".$(dirname "$p")"
      curl -sSL -A "$UA" "$BASE$p" -o ".$p" || echo "skip $p"
  done

# 3. rewrite absolute URLs to relative so it runs offline
sed -i "s#https://revolutionmacro.com/#/#g" index.html
# optional: staging host used by some og:image tags
sed -i "s#https://staging.revolutionmacro.com/#/#g" index.html

echo "Done -> $(pwd)/index.html"
python3 -m http.server 8080   # serve it; ES modules need http:// not file://