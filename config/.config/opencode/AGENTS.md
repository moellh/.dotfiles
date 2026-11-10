# Global Agent Instructions

## Rules

> Adhere to these rules unless told otherwise.

- When sudo requires password (no passwordless sudo), ask user to run the command yourself.

## Information

> Just some context information.

- This file's location: `~/.config/opencode/AGENTS.md`.
- OS: Arch Linux
    - Arch has `pacman` and `yay` (or my custom install script `yay-install`) for installing/removing packages. Never install/remove packages yourself and instead tell me, when a package should be installed/removed, so i can do it for you.
- Laptop `aspire`:
    - Contains NVIDIA GTX 1050 GPU.

## Available Tools

### Research tools

You have access to web tools. **Use them liberally** — don't guess when you can verify.
Besides looking up documentation that already exists locally and therefore likely perfectly documents installed programs, use web search or web fetch, whenever you feel like it may be useful to get accurate information.

| Tool | When to use | How |
|------|-------------|-----|
| `webfetch` | Specific URLs (docs, changelogs, GitHub releases) | `webfetch url=<URL>` |
| `web_search` | General queries, "latest", "current", version checks | Ollama API via curl |

**Ollama Web Search command:**
```bash
source ~/data/env && curl -s https://ollama.com/api/web_search \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -d "{\"query\": \"your search query\"}"
```

**Use web tools when:**
- User says "research", "look up", "check", "latest version"
- Any version number, release date, or current event
- API changes, breaking changes, deprecation notices
- Package/library documentation beyond your training cutoff
- Uncertainty about current best practices

**Don't wait to be asked.** If current info improves the answer, fetch it.

## Getting Current Information

> How to handle knowledge gaps due to model training cutoffs.

AI models have a knowledge cutoff date (~2025). To get accurate, up-to-date information, **always use web tools** rather than guessing:

- **`webfetch`**: For specific URLs (docs, changelogs, articles)
- **`web_search` via Ollama API**: For general queries when you don't have a specific URL

**Trigger**: Any request involving dates, versions, current events, "latest", "recent", or when the user implies the information might be newer than your training data.

### Image Interpretation

Use Ollama vision models when you need to analyze or interpret images (diagrams, screenshots, photos, handwritten content, etc.).

**Bash:**
```bash
base64 -w0 /path/to/image.png | {
  printf '{"model":"kimi-k2.5:cloud","think":false,"messages":[{"role":"user","content":"Describe this image in detail","images":["'
  cat
  printf '"]}],"stream":false}'
} | curl -s http://localhost:11434/api/chat -d @- | python3 -c "import sys,json; print(json.load(sys.stdin)['message']['content'])"
```

**When to use:**
- Analyzing diagrams, charts, figures
- Reading handwritten content in images
- Extracting structured info from screenshots
- Any time visual content needs interpretation

**For PDFs:** Use the `pdf-analyzer` skill (dual-pass: pdftotext + vision per page).
