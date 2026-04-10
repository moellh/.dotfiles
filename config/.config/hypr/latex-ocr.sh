#!/bin/bash

tmp_img=$(mktemp /tmp/screenshot-XXXXXX.png)

slurp | grim -g - "$tmp_img" || exit 1

img_base64=$(base64 -w 0 "$tmp_img")

prompt='Generate LaTeX math code from the image. Output exactly one version. Do not surround with $$ or similar - assume it is already surrounded by \\[\\]. Use \\begin{align}\\end{align} when it makes sense, e.g. for multiline equation. Output ONLY the LaTeX code, no explanations. Example output: \frac{1}{2}x^2 + 3x + 5, not \\[\\frac{1}{2}x^2 + 3x + 5\\]'

response=$(curl -s http://localhost:11434/api/generate \
  -d "{\"model\":\"kimi-k2.5:cloud\",\"prompt\":\"$prompt\",\"stream\":false,\"think\":false,\"images\":[\"$img_base64\"]}")

result=$(echo "$response" | jq -r '.response // empty')

echo -n "$result" | wl-copy

rm "$tmp_img"

notify-send "LaTeX OCR" "Copied to clipboard"
