#!/bin/bash

# Vault names
VAULTS=(
  "devault"
  "gq"
  "pn"
  "rl"
  "mc"
  "thw"
)

# Use rofi to select a vault
VAULT=$(printf "%s\n" "${VAULTS[@]}" | rofi -dmenu)

# Exit if nothing selected
[ -z "$VAULT" ] && exit 1

# Open Obsidian URL
xdg-open "obsidian://open?vault=$VAULT"
