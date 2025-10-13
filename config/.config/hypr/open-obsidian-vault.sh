#!/usr/bin/env bash

# Vault names
VAULTS=(
  "devault"
  "rl"
  "fm"
  "mc"
  "rtc"
  "do"
  "vs"
  "soas"
  "thw"
)

# Use rofi to select a vault
VAULT=$(printf "%s\n" "${VAULTS[@]}" | rofi -dmenu)

# Exit if nothing selected
[ -z "$VAULT" ] && exit 1

# Open Obsidian URL
xdg-open "obsidian://open?vault=$VAULT"
