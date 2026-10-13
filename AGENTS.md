# Agent instructions

## Agent configuration

Keep all agent configuration for this repo in the tool-neutral layout: instructions in `AGENTS.md`, skills in
`.agents/skills/`, and anything else agent-related under `.agents/`. Never create tool-specific files or directories
such as `CLAUDE.md`, `.claude/`, `GEMINI.md`, `.cursor/` or `.github/copilot-instructions.md`. If a tool does not read
`AGENTS.md` on its own, read it yourself before working here instead of adding a tool-specific copy or pointer file.

## Commit messages

Use [Scoped Commits](https://scopedcommits.com) for every commit:

```
<scope>: <description>

[optional body]

[optional trailer(s)]
```

- The scope is the config or area the commit touches, usually the directory under `config/.config/` or a top-level
  file: `hypr`, `nvim`, `tmux`, `waybar`, `zsh`, `scripts`, `systemd`, `wallpapers`, `packages`, `agents`. Check
  `git log` for an existing scope before inventing a new one.
- No Conventional Commits type prefixes (`feat(hypr): ...`, `fix: ...`). Older history uses them, new commits don't.
- One scope per commit: split unrelated changes into separate commits. If a single change really spans several scopes,
  list them comma-separated (`nvim, git: ...`), or use `treewide` when it touches everything.
- Description: lowercase, imperative, no trailing period, and specific about what changed (not just "update").
- The body is optional. Use it for the why, or to list the parts of a larger change.
- Never add agent attribution: no `Co-Authored-By:` trailer naming an AI agent or tool, and no "Generated with ..."
  line, in commit messages or pull request descriptions.
