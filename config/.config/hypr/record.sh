#!/usr/bin/env bash

RECORDING_PID_FILE="/tmp/wf-recorder.pid"

# Already recording, stop it
if [[ -f "$RECORDING_PID_FILE" ]]; then
    PID=$(cat "$RECORDING_PID_FILE")
    kill "$PID"
    rm "$RECORDING_PID_FILE"

# Not recording
else
    # Select area with slurp
    GEOM=$(slurp)
    [ -z "$GEOM" ] && exit 1  # Exit if no area selected

    # Start recording the selected area
    wf-recorder -g "$GEOM" -f ~/Videos/recording-$(date +'%Y%m%d-%H%M%S').mp4 &
    echo $! > "$RECORDING_PID_FILE"
fi
