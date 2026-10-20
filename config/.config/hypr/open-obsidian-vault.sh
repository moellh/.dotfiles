#!/usr/bin/env bash

# Vault names
VAULTS=(
  "devault"
  "hpc"
  "cv"
  "rl"
  "mpl"
  "grw"
  "sce"
  "arl"
  "agp"
  "mr"
  "fm"
  "digi-ops"
  "spscg"
  "thw"
)

# Use rofi to select a vault
VAULT=$(printf "%s\n" "${VAULTS[@]}" | rofi -dmenu)

# Exit if nothing selected
[ -z "$VAULT" ] && exit 1

# Obsidian can lose a vault's window when a monitor is disabled (e.g. lid closed)
# while the process keeps running. Obsidian still considers that vault open, so
# opening it again only "focuses" the missing window and nothing appears. All
# vault windows share one process, so the only fix is restarting it and
# reopening every vault that was open.
OBSIDIAN_JSON="$HOME/.config/obsidian/obsidian.json"

# Vault names (folder basenames) that Obsidian considers open.
open_vaults() {
  jq -r '.vaults[] | select(.open) | .path | split("/") | last' "$OBSIDIAN_JSON" 2>/dev/null
}

# Vault names that have a window in Hyprland. Titles look like
# "<note> - <vault> - Obsidian <version>" or "<vault> - Obsidian <version>".
visible_vaults() {
  hyprctl clients -j \
    | jq -r '.[] | select(.class == "md.obsidian.Obsidian") | .title' \
    | sed -E 's/ - Obsidian [0-9.]+$//; s/.* - //'
}

obsidian_window_count() {
  hyprctl clients -j | jq '[.[] | select(.class == "md.obsidian.Obsidian")] | length'
}

main_pid=$(pgrep -f -o '^/usr/lib/electron[0-9]*/electron /usr/lib/obsidian/app.asar')
if [ -n "$main_pid" ] && [ "$(ps -o etimes= -p "$main_pid")" -gt 15 ] \
  && open_vaults | grep -qxF "$VAULT" && ! visible_vaults | grep -qxF "$VAULT"; then
  mapfile -t reopen < <(open_vaults | grep -vxF "$VAULT")

  pkill -f 'obsidian/app.asar'
  for _ in $(seq 20); do pgrep -f 'obsidian/app.asar' >/dev/null || break; sleep 0.25; done

  # Reopen the other vaults first, then the requested one so it ends up focused.
  # Wait for each window so launches don't race the starting process.
  for v in "${reopen[@]}" "$VAULT"; do
    before=$(obsidian_window_count)
    xdg-open "obsidian://open?vault=$v"
    for _ in $(seq 40); do [ "$(obsidian_window_count)" -gt "$before" ] && break; sleep 0.25; done
  done
  exit 0
fi

# Open Obsidian URL
xdg-open "obsidian://open?vault=$VAULT"
