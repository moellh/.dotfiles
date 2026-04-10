---
name: skill-authoring
description: Create valid SKILL.md files with proper frontmatter, naming conventions, and placement for OpenCode and compatible agents
---

# Skill Authoring Guide

Guide for creating reusable, auto-discoverable skill files for OpenCode, Claude Code, and other Agent Skill-compatible platforms.

## Resources

- Official docs: https://opencode.ai/docs/skills
- Template: `./TEMPLATE.md`
- Example: `./examples/minimal/EXAMPLE-SKILL.md`

## Placement Locations

Skills are discovered from these locations:

- Project: `<project>/.opencode/skills/<name>/SKILL.md`
- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Claude-compatible: `.claude/skills/<name>/SKILL.md` or `~/.claude/skills/<name>/SKILL.md`
- Agent-compatible: `.agents/skills/<name>/SKILL.md` or `~/.agents/skills/<name>/SKILL.md`

Global skills in `~/.config/opencode/skills/` are available across all projects.

## YAML Frontmatter (Required)

Every SKILL.md must start with YAML frontmatter containing:

```yaml
---
name: your-skill-name
description: Brief description (1-1024 chars) used for auto-discovery
---
```

The `name` field is required and must:
- Be 1-64 characters
- Use lowercase alphanumeric with single hyphen separators
- Match the directory name containing SKILL.md
- Not start/end with `-` or contain consecutive `--`

## Instructions

When creating a new skill:

1. Choose a specific kebab-case name (e.g., `api-review`, not `utils`)
2. Create directory matching the name: `mkdir -p ~/.config/opencode/skills/<name>/`
3. Write SKILL.md with required frontmatter first, then content
4. Keep description specific so agents can auto-discover correctly
5. Test by asking the agent to "use the <name> skill"

## Example Structure

```
~/.config/opencode/skills/
└── my-skill/
    └── SKILL.md
```

## Anti-patterns

- Missing frontmatter (skill won't be discovered)
- Name not matching directory name
- Generic descriptions like "helper" or "utilities"
- Skills in repo root instead of `.opencode/skills/` or global config
