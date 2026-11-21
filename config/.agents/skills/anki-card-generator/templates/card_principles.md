# Anki Card Generation Principles

Reference guide for generating high-quality Anki flashcards.

## Basic Card Format (6 Fields)

Tab-separated columns:

```
Name[tab]Alternative Names[tab]Front Text[tab]Back Text[tab]Reverse[tab]Notes[tab]Tags
```

### Field Specifications

#### Name (Required)
- **Purpose**: Primary identifier and front side of card
- **Style**: Title Case / Scientific Title Case
- **Length**: 2-5 words max
- **Content**: The key term, concept, or question topic
- **Examples**:
  - `Priority Inversion`
  - `EDF Scheduling`
  - `Deferrable Server`
  - `What is Zephyr OS?`

#### Alternative Names (Optional)
- **Purpose**: Synonyms, acronyms, alternative terminology
- **Style**: Each term in **bold** (`<b>Term</b>`)
- **Separator**: Single space or comma
- **Examples**:
  - `<b>Makespan</b>` (for Latest Completion Time)
  - `<b>Priority Ceiling Protocol</b> <b>PCP</b>`
  - `<b>RTOS</b>` (for Real-Time Operating System)

#### Front Text (Often Empty)
- **Purpose**: Additional context when Name alone is insufficient
- **Style**: Normal sentence case
- **Use When**: 
  - Name is too brief
  - Additional context needed for understanding
- **Examples**:
  - `In Zephyr's scheduling, `
  - `For periodic tasks with deadline = period, `
  - Empty (most cards)

#### Back Text (Required)
- **Purpose**: The answer content
- **Style**: Normal sentence case, sparing formatting
- **Formatting**:
  - `<ul><li>Item 1</li><li>Item 2</li></ul>` for bullet lists
  - `<ol><li>First</li><li>Second</li></ol>` for numbered lists
  - `<b>bold</b>` for key terms
  - `<i>italics</i>` for emphasis
  - `<br>` for line breaks
  - `<code>code</code>` for inline code
  - `<pre>...</pre>` for code blocks
- **Principles**:
  - One concept per card
  - Minimal content (Anki best practice)
  - Split complex answers into multiple cards

#### Reverse (Optional: `y`)
- **Purpose**: Enable reverse direction card
- **Use When**:
  - Term should be learnable both ways
  - Name ↔ Context bidirectional learning needed
  - Acronym cards where both directions matter

#### Notes (Optional)
- **Purpose**: Additional context, examples, references
- **Style**: Brief, supplementary information
- **Include**:
  - `TODO ADD PICTURE: Description (page X)`
  - Cross-references: "See also: related concept"
  - Examples: "E.g., Task scheduling scenario"
  - Caveats: "Note: Only applies when..."

#### Tags (Required)
- **Purpose**: Organizational hierarchy
- **Format**: `source::section::subsection`
- **Style**: Lowercase with colons
- **Examples**:
  - `rtos::scheduling::edf`
  - `rtos::synchronization::mutex`
  - `zephyr::devicetree`

---

## File Headers

### Basic Cards
```
#separator:Tab
#html:true
#notetype:Basic
#deck:DeckName
#tags column:7
```

### Cloze Cards
```
#separator:Tab
#html:true
#notetype:Cloze
#deck:DeckName
#tags column:3
```

---

## Cloze Deletion Patterns

### Multi-Deletion (Related Concepts)
Use when deletions reinforce each other:

```
{{c1::Priority Inversion}} occurs when a {{c2::high-priority}} task is blocked by 
a {{c3::low-priority}} task holding a shared resource.
```

`c1` is the main concept. `c2` and `c3` are related context that should be learned together.

### Same Group Multiple Times
Use when same concept appears twice:

```
{{c1::EDF}} assigns higher priority to tasks with {{c2::earlier deadlines}}. 
Under {{c1::EDF}}, utilization can reach 100%.
```

Both `{{c1::EDF}}` deletions are tested together.

### Single Deletion
Use for focused learning:

```
Under IPCP, a task can be blocked at most {{c1::once}} by a lower-priority 
critical section.
```

### Guideline: Multi vs Single
- **Multi-deletion**: Concepts that should be learned as a unit
- **Single-deletion**: Standalone facts
- **Split**: Long sentences with 4+ potential deletions

---

## Image Reference Format

### In Cards
```
TODO ADD PICTURE: Thread state transition diagram (slide 23)
TODO ADD PICTURE: Gantt chart comparing EDF vs RM (page 78)
```

### In figures.md
```markdown
### Slide 23: Thread State Machine
- Content: State diagram showing Running, Ready, Suspended, Pending
- Use for: Image occlusion card
- TODO ADD PICTURE: State transition diagram showing all transitions

### Cards Requiring Manual Insertion

| Card: State Transitions | Thread state diagram | p.23 |
| Card: EDF Scheduling | Gantt comparison | p.78 |
```

---

## Content Coverage Principles

### 1. Comprehensive Coverage
- Generate cards for **ALL** concepts mentioned
- Over-generation is preferred
- Users can delete irrelevant cards

### 2. Card Splitting

**Bad** (overloaded):
```
Back: EDF is dynamic priority. Rate Monotonic is static priority. EDF can achieve 
100% utilization. RM is limited to ~69.3%. EDF is unpredictable under overload. 
RM maintains predictable behavior. EDF requires deadline tracking.
```

**Good** (split):
```
Card 1: EDF vs RM - Priority Type
Back: <b>EDF</b> uses <b>dynamic</b> priority. <b>Rate Monotonic</b> uses <b>static</b> priority.

Card 2: EDF vs RM - Utilization
Back: <b>EDF</b> achieves up to <b>100%</b> utilization. <b>Rate Monotonic</b> is limited to 
<b>~69.3%</b> worst case.

Card 3: EDF vs RM - Overload Behavior
Back: <b>EDF</b> is <b>unpredictable</b> under overload. <b>Rate Monotonic</b> maintains 
<b>predictable</b> behavior.
```

### 3. Minimal Front, Focused Back

**Bad**:
```
Front: What is EDF, how does it work, what are its advantages and disadvantages, 
and when should you use it?
```

**Good**:
```
Name: EDF Scheduling
Back: <b>Earliest Deadline First</b> — dynamic priority algorithm where the task 
with the <b>earliest deadline</b> gets highest priority.
```

### 4. Technical Notation

Preserve from source:
- Mathematical formulas: `U ≤ n(2^(1/n) - 1)`
- Code: `<code>k_thread_create()</code>`
- Acronyms: Define on first use, then use acronym

---

## Tag Hierarchy Examples

### Lecture-Based
```
rtos::intro::concepts
rtos::scheduling::rate-monotonic
rtos::scheduling::edf
rtos::scheduling::acceptance-tests
rtos::synchronization::mutex
rtos::synchronization::priority-inversion
```

### Code-Based
```
zephyr::api::threads
zephyr::api::timers
zephyr::api::gpio
zephyr::config::kconfig
zephyr::config::devicetree
```

### Exercise-Based
```
exercises::chatterbox::threads
exercises::tda::acceptance-tests
exercises::edf::deferrable-server
exercises::pcp::ipcp
```

---

## Examples by Content Type

### Definition Cards
```
What is a Deferrable Server?	<b>DS</b>			<ul><li>Periodic server for aperiodic tasks</li><li>Fixed period and budget</li><li>Budget does not accumulate</li></ul>		y	rtos::scheduling::deferrable-server
```

### Comparison Cards
```
Mutex vs Semaphore			<ul><li><b>Mutex</b>: ownership, PIP, NOT ISR-safe</li><li><b>Semaphore</b>: no ownership, give is ISR-safe</li></ul>		rtos::synchronization
```

### Formula Cards
```
EDF Schedulability Test	<b>Utilization Test</b>					∑(Ci/Ti) ≤ 1.0 for D=T (necessary and sufficient)		rtos::scheduling::edf
```

### Code Cards
```
Zephyr Timer Sync Pattern	<b>Periodic Task Pattern</b>					<code>k_timer_status_sync(&timer)</code> blocks until next period boundary. Preferred over <code>k_msleep()</code> to avoid drift.		zephyr::timers
```

### Acronym Cards
```
Long form of RTOS	<b>Real-Time Operating System</b>			acronyms
Long form of EDF	<b>Earliest Deadline First</b>		y	acronyms
```

---

## Quality Checklist

Before outputting, verify:

- [ ] Every section/subsection has cards
- [ ] Technical terms are properly capitalized
- [ ] Acronyms have definition cards
- [ ] Formulas are preserved
- [ ] Code snippets use `<code>` tags
- [ ] Lists use `<ul>/<ol>` HTML
- [ ] Tags follow `source::section::subsection` format
- [ ] Image placeholders for all figures/diagrams
- [ ] Long answers are split into multiple cards
- [ ] Related concepts in clozes use same group number