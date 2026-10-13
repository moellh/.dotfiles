#!/bin/sh
# Lock with the desktop still visible: enable session_lock_xray for the duration of hyprlock, then restore it.

pidof hyprlock >/dev/null && exit 0

prev=$(hyprctl -j getoption misc:session_lock_xray | grep -q '"bool": true' && echo true || echo false)
hyprctl eval 'hl.config({ misc = { session_lock_xray = true } })' >/dev/null
hyprlock -c ~/.config/hypr/hyprlock-transparent.conf
hyprctl eval "hl.config({ misc = { session_lock_xray = $prev } })" >/dev/null
