# Anki Card Generator Skill

Generate Anki flashcards from PDFs, lecture slides, and text files.

## Quick Start

```bash
# Check dependencies
python3 anki-card-generator/pdf_reader.py --check-deps

# Process a PDF (text only)
python3 anki-card-generator/pdf_reader.py slides.pdf --text-only -o output.json

# Process a PDF (with vision analysis)
python3 anki-card-generator/pdf_reader.py slides.pdf -o output.json
```

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions for OpenCode/Claude Code |
| `pdf_reader.py` | Python script for PDF processing |
| `templates/card_principles.md` | Card generation guidelines |

## Output Files

The skill generates:
- `<deck_name>_basic.txt` — Basic cards (6-field format)
- `<deck_name>_cloze.txt` — Cloze deletion cards
- `<deck_name>_figures.md` — List of pages with figures for image occlusion

## Installation

```bash
# Python dependencies
pip install ollama pdf2image

# System dependencies (Ubuntu/Debian)
sudo apt-get install poppler-utils
```

## Usage from OpenCode

```
User: Generate Anki cards from lecture/Chapter4-Scheduling.pdf

OpenCode: [Loads SKILL.md] → [Runs pdf_reader.py] → [Generates cards]
```

## Card Format

### Basic Cards (6 fields, tab-separated):
```
Name[TAB]Alternative Names[TAB]Front Text[TAB]Back Text[TAB]Reverse[TAB]Notes[TAB]Tags
```

### Cloze Cards:
```
{{c1::Concept A}} is related to {{c2::Concept B}}.	[TAB]	source::section
```

## Vision Model

Uses Ollama with `kimi-k2.5:cloud` by default. Configure with:
```bash
python3 pdf_reader.py slides.pdf -m llama3.2-vision -o output.json
```