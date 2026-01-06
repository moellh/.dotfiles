#!/bin/bash

# Define the transparent placeholder
PLACEHOLDER="/tmp/transparent_placeholder.png"

# Ensure placeholder exists
if [[ ! -f "$PLACEHOLDER" ]]; then
    magick -size 1x1 xc:transparent "$PLACEHOLDER"
fi

# Check if music is playing
STATUS=$(playerctl status 2>/dev/null)

if [[ "$STATUS" != "Playing" ]]; then
  if [[ "$1" == "--art" ]]; then
    echo "$PLACEHOLDER"
  fi
  # For text options, return empty string
  exit 0
fi

if [[ "$1" == "--title" ]]; then
  TITLE=$(playerctl metadata title)
  # Truncate if too long?
  if [ ${#TITLE} -gt 50 ]; then
    echo "${TITLE:0:50}..."
  else
    echo "$TITLE"
  fi
elif [[ "$1" == "--artist" ]]; then
  ARTIST=$(playerctl metadata artist)
  if [ ${#ARTIST} -gt 50 ]; then
    echo "${ARTIST:0:50}..."
  else
    echo "$ARTIST"
  fi
elif [[ "$1" == "--art" ]]; then
  URL=$(playerctl metadata mpris:artUrl 2>/dev/null)
  if [[ -z "$URL" ]]; then
    echo "$PLACEHOLDER"
    exit 0
  fi

  if [[ "$URL" == file://* ]]; then
    echo "${URL#file://}"
  elif [[ "$URL" == http* ]]; then
    # Simple hash of the URL to cache the image
    HASH=$(echo -n "$URL" | sha256sum | awk '{print $1}')
    CACHE_FILE="/tmp/cover_$HASH.jpg"

    if [[ ! -f "$CACHE_FILE" ]]; then
       # Download silently
       curl -s "$URL" -o "$CACHE_FILE"
    fi
    echo "$CACHE_FILE"
  else
    echo "$PLACEHOLDER"
  fi
elif [[ "$1" == "--time" ]]; then
    LENGTH=$(( $(playerctl metadata mpris:length 2>/dev/null) - 10000000 ))
    POSITION=$(playerctl position 2>/dev/null)
    TITLE=$(playerctl metadata title 2>/dev/null)

    if [[ -z "$LENGTH" || -z "$POSITION" ]]; then exit 0; fi
    if [[ "$LENGTH" -eq 0 ]]; then exit 0; fi

    # Convert to integer seconds
    LEN_SEC=$(echo "$LENGTH / 1000000" | bc)
    POS_SEC=${POSITION%.*}

    if [ "$LEN_SEC" -le 0 ]; then exit 0; fi

    # --- PERSISTENT SCATTERED BRAILLE LOGIC ---

    BAR_WIDTH=200  # Wider bar

    # Calculate current percentage (0-100)
    PERC=$(echo "$POS_SEC * 100 / $LEN_SEC" | bc)

    # 1. Create a deterministic seed from the Song Title.
    #    This ensures the 'random' pattern is unique to this song,
    #    but stays the same (persistent) every time we check it.
    SEED=$(echo "$TITLE" | cksum | cut -d' ' -f1)

    # 2. Seed the Random Generator
    RANDOM=$SEED

    BAR=""

    # Base Braille Unicode is U+2800 (hex) = 10240 (decimal)
    BRAILLE_BASE=10240

    # 3. Generate the Bar
    for ((i=0; i<BAR_WIDTH; i++)); do
        CHAR_VAL=0

        # Iterate through all 8 dots of a Braille character
        # Weights: 1, 2, 4, 8, 16, 32, 64, 128
        for bit in 1 2 4 8 16 32 64 128; do
            # For every single dot, we assign a random "Activation Threshold" (0-100)
            # Since the seed is fixed for this song, this threshold is constant!
            THRESHOLD=$(( RANDOM % 101 ))

            # If current song progress > this dot's threshold, turn the dot on.
            if [ "$PERC" -gt "$THRESHOLD" ]; then
                CHAR_VAL=$(( CHAR_VAL + bit ))
            fi
        done

        # Convert the calculated value to the Unicode Hex string
        # e.g. 10240 + 5 -> 10245 -> printf %x -> 2805 -> \u2805
        HEX_CODE=$(printf '%x' $(( BRAILLE_BASE + CHAR_VAL )))

        BAR="${BAR}\u${HEX_CODE}"
    done

    # -e enables interpretation of backslash escapes like \u
    echo -e "$BAR"
fi
