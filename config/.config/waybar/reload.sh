#!/bin/bash

trap "killall waybar" EXIT

while true; do
    waybar &
    inotifywait -e modify,create ~/.config/waybar
    killall waybar
done
