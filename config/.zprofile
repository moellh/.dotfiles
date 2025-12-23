# Start Hyprland automatically after login to TTY1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec Hyprland
fi
