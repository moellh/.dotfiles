# User scripts for the whole session, including Hyprland and the apps it starts
# (e.g. URL handlers in ~/.local/share/applications that call scripts by name).
export PATH="$PATH:$HOME/.scripts:$HOME/.local/bin"

# Start Hyprland automatically after login to TTY1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec start-hyprland
fi
