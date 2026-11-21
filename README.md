# Dotfiles

This repo contains my config files which I would like to backup and eventually install on a new machine.

For installation, just run `install.sh` in the `.dotfiles` directory.  This will also use zsh as the default shell.  So
source the `rc` file of the currently set shell to apply the changes to the current session.

To apply config on a system where files already exist (uses file-level symlinks, safe for mixed directories):

```bash
stow --no-folding config -t ~
```

System config (`/etc`, boot entry, services to enable) lives in `system/` as plain copies; see
[`system/README.md`](system/README.md) and run `system/install.sh`.

Machine-specific shell settings go into `~/.zshrc.local` (not in git), which `.zshrc` sources at the end.

`packages.txt` contains a list of packages for Neovim LSP servers, formatters, and other tools.

## Configs

### Core
- Neovim in `.config/nvim`
- Tmux in `.config/tmux`
- Kitty in `.config/kitty`
- Zsh in `.zshrc`
- Git in `.config/git/`

### Desktop (Hyprland)
- Hyprland in `.config/hypr/`
- Waybar in `.config/waybar/`
- Rofi in `.config/rofi/`
- Hyprmoncfg (monitor profiles) in `.config/hyprmoncfg/`

### Themes & Portals
- GTK 3/4 in `.config/gtk-3.0/`, `.config/gtk-4.0/`
- Qt5ct/Qt6ct in `.config/qt5ct/`, `.config/qt6ct/`
- XDG Desktop Portal in `.config/xdg-desktop-portal/`
- MIME associations in `.config/mimeapps.list`

### Tools
- Lazygit in `.config/lazygit/`
- Dunst in `.config/dunst/`
- MPD + RMPC (music) in `.config/mpd/`, `.config/rmpc/`, visualizer Cava in `.config/cava/`
- mpv (with upscaling shaders) in `.config/mpv/`
- Yazi, btop, zellij, glow, ghostty and zed in their `.config/` folders
- Tailscale port bridges (`bridge-ctl`, Waybar module) in `.config/bridges/`
- Local LLMs (llama.cpp profiles) in `.config/llm/`, see its README

### AI agents
- Shared instructions in `.agents/AGENTS.md`; the OpenCode, Codex and `~/.config` copies are symlinks to it
- Shared skills in `.agents/skills/`, linked into `.config/opencode/skills/` and `.claude/skills/`
- Opencode in `.config/opencode/`, Claude Code settings and status line in `.claude/`

### Shell
- Zsh config in `.zshrc`, `.zprofile`
- PowerLevel10k in `.p10k.zsh`
- Dircolors in `.dircolors`
- Custom scripts in `.scripts/`

## Custom Scripts

All scripts use `#!/usr/bin/env bash` for portability (NixOS, etc.)

- `update`: system update; its first step runs `backup-secrets`
- `backup-secrets`: encrypted borg backup of credentials and private config that must not go into this public repo
  (SSH and GPG keys, KeePassXC key file, rclone, AWS, `/etc/hosts`, ...) to the storage box, via the cloud host
- `borg-pull`: copies all borg repos from the storage box to the external HDD
- `run-llm`, `llm-switch`, `llm-download`: local LLM server (see `.config/llm/README.md`)

## Google Drive with RClone Bisync

1. Ensure that `rclone` is installed
2. See `rclone.conf` file in my Google Drive and copy it manually to `~/.config/rclone/rclone.conf`
3. Execute `mkdir ~/drive` and `touch .RCLONE_TEST` to create the local directory and test file
4. Execute `cloudsync --resync` (see `config/.scipts/cloudsync` for the rclone options it uses)

This downloads all files in my Google Drive to the `~/drive/` directory. The `update` script automatically calls
`cloudsync` to ensure that the folders is up to date. To update it manually, simply execute `cloudsync`. On errors, it
may be necessary to run the command with `--resync` or `--force` depending on the given error.
