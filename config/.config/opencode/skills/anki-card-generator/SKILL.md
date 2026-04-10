---
name: anki-card-generator
description: Generate Anki flashcards (Basic and Cloze) from source materials (PDFs, lecture slides, text files). Uses dual-pass PDF analysis with pdftotext and Ollama vision models. Outputs import-ready .txt files and figures.md for manual image occlusion.
---

# Anki Card Generator Skill

Generate high-quality Anki flashcards from educational materials through **manual curation by the LLM**.

## Terminology

Understanding Anki's data model is essential for card generation:

### Note vs Card

- **Note**: A single record in Anki's database. A note contains fields (text content) and can generate one or more cards depending on the note type.

- **Card**: An individual flashcard that the user answers. Cards are generated from notes based on the note type:
  - **Basic notes**: Generate 1 card (or 2 with Reverse=y)
  - **Cloze notes**: Generate N cards where N = the number of unique cloze deletions (`{{c1::...}}`, `{{c2::...}}`, etc.)
  - Multiple cloze deletions with the **same number** (`{{c1::...}}` appears multiple times) create only **one card** - they are revealed together

### Examples

**Basic Note (1 card):**
```
DMA	short <b>Direct Memory Access</b>		Hardware mechanism for transferring data...
```
→ 1 card asking "What is DMA?"

**Basic Note with Reverse=y (2 cards):**
```
WWAN	short <b>Wireless Wide Area Network</b>		Cellular networks...	y
```
→ Card 1: "WWAN → What does it stand for and what is it?"
→ Card 2: "Wireless Wide Area Network → What is the acronym?"

**Cloze Note (3 cards):**
```
IoT - everything connected to the Internet, equipped with {{c1::sensors}} and {{c2::actuators}}.
```
→ Card 1: Tests "sensors"
→ Card 2: Tests "actuators"

**Cloze Note with same number (1 card):**
```
The {{c1::Application}} and {{c1::Transport}} layers are end-to-end.
```
→ 1 card that reveals both Application AND Transport together

### Semantic Duplicate Detection

When checking for duplicate concepts, compare **cards** (what the user actually answers), not just notes. A single cloze note with multiple deletions creates multiple cards, and each must be checked against Basic cards.

## Workflow

When the user asks to generate Anki cards:

### 1. Gather Source Material

Ask the user for:
- **Source file(s)**: PDFs, .txt files, or .md files
- **Deck name** (optional): If not provided, infer from content/filename
- **Output directory** (optional): Defaults to source file directory as `<basename>_analysis.json`

### 2. Process Source Files

#### For PDF Files:
```bash
python /path/to/skill/pdf_reader.py <pdf_path>
```

The script outputs JSON to `<pdf_dir>/<pdf_basename>_analysis.json` with:
- Document title and summary
- Section structure
- Per-page content, key concepts, and figure descriptions

#### For Text/Markdown Files:
Read directly and analyze content structure.

### 3. Generate Cards MANUALLY

**CRITICAL: Cards must be manually curated by the LLM reading the JSON analysis. Do NOT use automated scripts.**

The LLM should:
1. Read the JSON analysis thoroughly
2. Identify key concepts worth memorizing
3. Skip organizational slides (title, outline, literature, thank you)
4. Avoid duplicate cards for the same concept
5. Create self-contained Q→A cards
6. Use own knowledge to improve cards but stay close to source material
7. **Prioritize exact definitions** — use the precise wording from the lecture, not paraphrased versions
8. **Capture ALL algorithms and pseudo-code** — these are frequently missed but highly exam-relevant. Transcribe step-by-step procedures, protocol sequences, and algorithmic conditions in full
9. **Include quantitative details** — specific numbers, rates, sizes, formulas, and thresholds are testable facts
10. **Check handwritten annotations** — the `handwritten_annotations` field in the JSON may contain important clarifications, corrections, or exam hints added by the lecturer
11. **Don't be too brief** — while Anki best practice favors short cards, cards covering algorithms, protocol flows, or multi-step processes should be as long as needed to be self-contained

#### Basic Cards (7-field format, tab-separated):
```
Name[tab]Alternative Names[tab]Front Text[tab]Back Text[tab]Reverse[tab]Notes[tab]Tags
```

| Field | Content |
|-------|---------|
| Name | Short concept/term (1-4 words, title case) |
| Alternative Names | `short <b>ACRONYM EXPANSION</b>` for acronyms - shows what the acronym stands for |
| Front Text | Additional context (often empty - Name field serves as question) |
| Back Text | Answer content with HTML formatting |
| Reverse | `y` ONLY for bidirectional recall (term↔definition, acronym↔long form) |
| Notes | Images via `<img src="paste-...">`, examples |
| Tags | Hierarchical: `source::section::subsection` |

#### Acronym Cards:
Create TWO cards for each acronym:

1. **Concept card with acronym**: `DMA` with `short <b>Direct Memory Access</b>` in Alt Names, definition in Back Text, Reverse=`y`
2. **Standalone acronym lookup**: `Long form of DMA` with empty Alt Names, empty Front Text, `<b>Direct Memory Access</b>` in Back Text, empty Reverse

**IMPORTANT**: The `short <b>...` format in Alt Names is ONLY for acronyms. For regular concept definitions, put the term in Name field and definition in Back Text, leaving Alt Names empty.

**Good:**
- `WWAN` with `short <b>Wireless Wide Area Network</b>` in Alt Names, Reverse=`y` (acronym with bidirectional recall)
- `Long form of WWAN` with `<b>Wireless Wide Area Network</b>` in Back Text (standalone lookup)
- `Mobile Computing` with definition in Back Text, Alt Names empty (concept)

**Bad:**
- `Mobile Computing` with `long <b>computing environment allowing...` in Alt Names (NOT an acronym)

#### File Header:
```
#separator:Tab
#html:true
#notetype:Basic
#deck:<DeckName>
#tags column:7
```

#### Cloze Cards (2-field format, tab-separated):
```
Text with {{c1::cloze deletions}}[tab]Tags
```

- Use same cloze number (`{{c1::}}`) for same concept expressed differently
- Use different numbers (`{{c1::}} {{c2::}} {{c3::}}`) for related but distinct concepts
- Group related concepts that belong together in one card
- Example: `Real-time = {{c1::reaction in time}}, not {{c2::fast}}.`

#### File Header:
```
#separator:Tab
#html:true
#notetype:Cloze
#deck:<DeckName>
#tags column:2
```

### 4. Figures.md

List all figures with page numbers and descriptions for MANUAL image occlusion creation.

**DO NOT create "describe the figure" Basic cards.** Figures are for image occlusion cards that the user creates manually.

**IMPORTANT**: Add `TODO: Insert <description> from p.XY` to the Notes field (column 6) of Basic cards that have relevant diagrams. This serves as a reminder to the user to insert images manually.

#### Structure:
1. **Header note** - State that Basic cards already have TODO notes in their Notes field
2. **Figure descriptions** - Context for each figure (optional reference material)
3. **Cards Requiring Manual Image Insertion** table with two sections:
   - **Basic Cards (Notes field)** - Lists which Basic cards have `TODO: Insert ...` notes
   - **Image Occlusion Cards** - Separate cards for active testing (new cards to create)

#### Example Header:
```markdown
# Figures for Manual Image Occlusion

**Note:** Cards with diagrams already have `TODO: Insert ...` notes in their Notes field in `<deck>_basic.txt`. This file provides additional context for manual image occlusion cards.
```

### 5. Output Files

Generate three files:
- `<output_dir>/<deck_name>_basic.txt` — Basic cards
- `<output_dir>/<deck_name>_cloze.txt` — Cloze cards
- `<output_dir>/<deck_name>_figures.md` — Figures for manual image occlusion

### 6. Quality Assurance

After generating output files, run the following verification checks:

#### Field Structure Verification:

```bash
# Verify Basic cards have exactly 7 fields (6 tabs)
awk -F'\t' '{print NF}' <deck>_basic.txt | sort | uniq -c
# Expected: all lines show 7 (except 5 for header)

# Verify Cloze cards have exactly 2 fields (1 tab)
awk -F'\t' '{print NF}' <deck>_cloze.txt | sort | uniq -c
# Expected: all lines show 2 (except 1 for header)
```

#### HTML Formatting Checks:

```bash
# Check for unescaped ampersands (should use &amp;)
grep -n '&' <deck>_basic.txt | grep -v '&amp;' | grep -v '\\('

# Check for incorrectly escaped HTML tags (should NOT use &lt; &gt; for tags)
grep -n '&lt;' <deck>_basic.txt

# Check for < in comparisons that should be &lt; (not HTML tags)
grep -n '< ' <deck>_basic.txt
# If found, replace with &lt; (e.g., "t_d < t_b" → "t_d &lt; t_b")
```

#### Reverse Field and Acronym Format Checks:

```bash
# Check Reverse field contains only "y" or empty
awk -F'\t' 'NR>5 {print $5}' <deck>_basic.txt | sort | uniq -c
# Expected: only empty lines and "y"

# Cards with Reverse=y should have acronym expansion in Alt Names (field 2)
awk -F'\t' 'NR>5 && $5=="y" && $2=="" {print $1}' <deck>_basic.txt
# These should be acronym cards with "short <b>EXPANSION</b>" in Alt Names

# Alt Names should use correct format: "short <b>...</b>" for acronyms only
# Check for "short <b>" format (correct for acronyms)
awk -F'\t' 'NR>5 && $2!="" && $2 !~ /^short <b>/ && $2 !~ /^long <b>/ {print NR": "$1" | "$2}' <deck>_basic.txt
```

#### Long Form Card Verification:

```bash
# "Long form of X" cards should have:
# - Empty Alt Names (field 2)
# - Empty Reverse (field 5)
# - Just "<b>EXPANSION</b>" in Back Text (field 4)
grep "^Long form of" <deck>_basic.txt
```

#### Duplicate Detection Across Files:

If generating from multiple PDFs in same course, check for semantic duplicates:

```bash
# Compare with existing output files
awk -F'\t' 'NR>5 {print $1}' outputs/*/_basic.txt | sort | uniq -c | sort -rn
# Names appearing multiple times may indicate duplicates

# Check for acronym expansions in cloze that duplicate basic
grep -E "{{c[0-9]+::.*Network}}|{{c[0-9]+::.*System}}|{{c[0-9]+::.*Multiplexing}}" <deck>_cloze.txt
```

#### Content Quality Checks:

1. Conformance to Card Generation Principles and Card Structure sections above
2. Anki best practices: self-contained cards, one concept per card, quality over quantity
3. No issues listed in HTML Formatting Rules, Reverse Field, or Figures sections
4. **No semantic duplicates** - avoid testing the same concept multiple times

#### Semantic Duplicate Checking:

Review the generated cards and eliminate redundancy:

**Example of semantic duplicate:**
- Basic: `MANET` with `short <b>Mobile Ad-hoc Network</b>` in Alt Names, Reverse=y
- Basic: `Long form of MANET` with `<b>Mobile Ad-hoc Network</b>` in Back Text
- Cloze: `MANET = {{c1::Mobile Ad-hoc Network}}`

All three test the same knowledge (acronym↔expansion). Keep:
- The acronym card with definition AND Reverse=y (tests term↔acronym bidirectionally)
- The "Long form of X" lookup card (simple acronym expansion)

**Avoid in Cloze:**
- `MANET = {{c1::Mobile Ad-hoc Network}}` — redundant with "Long form of MANET" Basic card
- `The acronym WWAN stands for {{c1::Wireless Wide Area Network}}` — redundant

**OK in Cloze (different enough):**
- `Wireless network types by range: {{c1::WWAN}} (widest), {{c2::WMAN}}, {{c3::WLAN}}, {{c4::WPAN}} (narrowest).` — tests ordering, not just expansion

Correct any issues found before finalizing.

## Common Gaps to Watch For

Based on review of generated card decks, these content types are frequently missed or underrepresented:

1. **Algorithms and pseudo-code** — Protocol sequences, routing algorithms, state machines, and step-by-step procedures are often skipped or oversimplified. Transcribe them in full.
2. **Formal mathematical conditions** — Edge removal conditions, schedulability tests, convergence conditions, etc. Include the actual formula, not just a verbal description.
3. **Handwritten annotations** — Lecturers often add important notes, corrections, or exam hints by hand on slides. The vision model extracts these into the `handwritten_annotations` field.
4. **Concrete examples with numbers** — Simulation results, calculation walk-throughs, and specific parameter values (e.g., "BER=10^-5 causes 54% throughput drop") make excellent exam cards.
5. **"Why" explanations** — Cards often capture "what" but miss "why" (e.g., why CSMA/CD fails in wireless, why 2PC is too expensive for mobile, why scalar clocks can't detect conflicts).
6. **Comparison tables** — When the lecture provides structured comparisons (advantages vs disadvantages, protocol A vs B), capture the full comparison, not just one side.
7. **Subtle distinctions** — Terms that sound similar but differ (e.g., "eventual consistency" vs "causal consistency" — the latter does NOT guarantee convergence).

## Card Generation Principles

### Quality Over Quantity
- ~2 cards per concept slide (some slides may have 0 cards, some 4+)
- Skip organizational slides (title, literature references, thank you)
- **Content overview slides ARE useful** - include lecture structure, chapter overviews, or topic agendas that help understand course organization
- One concept per card
- Examples go in Notes field, not separate cards

### Card Structure
- **Name field**: Short, self-contained (acts as question when Front Text is empty)
- **Front Text**: Often empty - Name field serves as the question
- **Alternative Names**: Use `long <b>Full Term</b>` or `short <b>ACRONYM</b>` format
- **Back Text**: Use HTML:
  - `<ul><li>...</li></ul>` for unordered lists
  - `<ol><li>...</li></ol>` for ordered lists
  - `<b>...</b>` for bold
  - `<br>` for line breaks
  - `&amp;` for ampersand (IMPORTANT: this is the ONLY escaped character)

### HTML Formatting Rules
- **DO NOT escape `<` and `>` as `&lt;` and `&gt;`** - HTML tags like `<ul>`, `<li>`, `<b>`, `<br>` must be plain
- **DO escape `&` as `&amp;`** - This is required for valid HTML
- For `<` in comparisons (e.g., `<1s`), use `&lt;` since it's not an HTML tag

### Math Notation
- **Inline math**: Use `\(...\)` for LaTeX, e.g., `\(\neq\)` for ≠, `\(\mu\)` for μ
- **Block math**: Use `\[...\]` or `$$...$$` for display equations
- **Variables**: Use LaTeX for variables to make them stand out: `\(d^2\)`, `\(c\)`, `\(n\)`
- Example: `Transmission power scales with \(d^2\) in free space.`

### Reverse Field
- Set Reverse = `y` ONLY when bidirectional recall makes sense
- Good for: term↔definition, acronym↔long form
- NOT for: lists, explanations, examples

### Self-Contained Cards
- Each card should make sense without external context
- BAD: "Definition" as Name field
- GOOD: "DMA" as Name field with definition in Back Text

### Figures
- NO "Describe the figure..." cards in Basic
- **Notes field**: Add `TODO: Insert <description> from p.XY` for supplementary visuals (not tested)
- **Image Occlusion cards**: List in figures.md for separate manual creation (actively tested)
- Note: The same figure can appear in BOTH Notes field and Image Occlusion cards

### Tags
- Use hierarchical format: `source::section::subsection`
- Example: `rts::introduction::definition`, `rts::challenges`
- Infer structure from document sections

## Example Output

### basic.txt:
```
#separator:Tab
#html:true
#notetype:Basic
#deck:RTOS Introduction
#tags column:7
DMA	short <b>Direct Memory Access</b>		Hardware mechanism for transferring data between I/O devices &amp; main memory, relieving CPU from controlling I/O data transfer.	y		rts::introduction::challenges
Long form of DMA			<b>Direct Memory Access</b>			rts::acronyms
Long form of WCET			<b>Worst-Case Execution Time</b>			rts::acronyms
```

### cloze.txt:
```
#separator:Tab
#html:true
#notetype:Cloze
#deck:RTOS Introduction
#tags column:2
Real-time = {{c1::reaction in time}}, not {{c2::fast}}.	rts::introduction::definition
RT tasks are classified as {{c1::hard}}, {{c2::firm}}, or {{c3::soft}} based on consequences of missed deadline.	rts::introduction::classification
{{c1::Testing and Debugging}} don't show correctness. Programs must be {{c1::composed correctly}} and need {{c1::sophisticated design, rigorous analysis methods}} to {{c1::prove correctness incl. timing behavior}}.	rts::introduction::lessons
```

### figures.md:
```markdown
# Figures for Manual Image Occlusion

**Note:** Cards with diagrams already have `TODO: Insert ...` notes in their Notes field in `<deck>_basic.txt`. This file provides additional context for manual image occlusion cards.

## Source: Lecture Slides

### Real-Time Systems Definition

**Page 4: Controlled System Diagram**
- Block diagram showing Input → Real-time Computing System → Output
- Callout about late reactions being dangerous

### DMA Architecture

**Page 17: DMA Block Diagram**
- CPU, Memory, I/O Device, DMA Device connections
- Memory bus sharing concept

## Cards Requiring Manual Image Insertion

### Basic Cards (Notes field)

| Card Name | Image Reference | Page |
|-----------|----------------|------|
| DMA | DMA block diagram | p.17 |

### Image Occlusion Cards (for manual creation)

| Card Name | Image Reference | Page |
|-----------|----------------|------|
| RTS Definition | Controlled System diagram | p.4 |
| DMA Architecture | CPU-Memory-I/O-DMA diagram | p.17 |
```

**Note:** Basic cards that reference figures have `TODO: Insert <description> from p.XY` in their Notes field, e.g.:
```
DMA	short <b>Direct Memory Access</b>		Hardware mechanism for transferring data between I/O devices &amp; main memory, relieving CPU from controlling I/O data transfer.	y	TODO: Insert DMA block diagram from p.17	rts::introduction::challenges
```

## Dependencies

### pdf_reader.py Requirements:
- Python 3.8+
- `ollama` library
- `pdftotext` CLI tool (poppler-utils)
- `pdf2image` package for rendering pages

### Installation:
```bash
pip install ollama pdf2image
# Ubuntu/Debian:
sudo apt-get install poppler-utils
```

### Virtual Environment:
Check if a `.venv` or `venv` virtual environment exists in the workspace. If it exists and contains the required packages (`ollama`, `pdf2image`), use it:
```bash
<venv_path>/bin/python <skill_path>/pdf_reader.py <pdf_path>
```
If no venv exists or dependencies are missing, create one and install packages.

## Usage Examples

**From PDF:**
```
User: Create Anki cards from lecture/Chapter1-Introduction.pdf put the outputs to outputs/
```

**Multiple files:**
```
User: Generate cards from lecture/Chapter3.pdf and lecture/Chapter4.pdf
```

**With explicit deck name:**
```
User: Generate cards from slides.pdf with deck name "RTOS Final Exam"
```

## Notes

- **MANUAL CURATION REQUIRED**: Do NOT use automated scripts. Read JSON, understand content, create cards thoughtfully.
- Preserve technical terminology from source
- HTML tags must be plain (not escaped): `<ul>`, `<li>`, `<b>`, `<br>` are correct
- Only `&` needs to be escaped as `&amp;`
- For `<` in comparisons, use `&lt;` (e.g., `<1s` → `&lt;1s`)
- **For math/variables in text, use LaTeX**: `\(d^2\)`, `\(c\)`, `\(\mu\)` - this makes them visually distinct
- Include content overview slides (lecture structure, chapter topics) - they help understand course organization
- Skip "image" slides (mostly photos) unless they have diagrams worth extracting
- Check for existing .txt files to infer deck naming conventions
- **Acronym handling**: Use `short <b>EXPANSION</b>` in Alt Names field for acronyms; do NOT use `long <b>...` format for non-acronym concepts
