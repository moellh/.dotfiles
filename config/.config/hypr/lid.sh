#!/bin/bash

# Deactive laptop monitor if first argument is NOT "open"

if [[ "$(hyprctl monitors)" =~ "HDMI-A-1" ]]; then
  if [[ $1 == "open" ]]; then
    hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x1080", scale = 1 })'
  else
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
  fi
fi
