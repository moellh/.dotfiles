#!/bin/bash

# Deactive laptop monitor if first argument is NOT "open"

if [[ "$(hyprctl monitors)" =~ "HDMI-A-1" ]]; then
  if [[ $1 == "open" ]]; then
    hyprctl keyword monitor "eDP-1,1920x1080@60.02,0x1080,1"
  else
    hyprctl keyword monitor "eDP-1,disable"
  fi
fi
