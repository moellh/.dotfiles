#!/bin/bash

# Define the transparent placeholder
PLACEHOLDER="/tmp/transparent_placeholder.png"
MUSIC_CACHE_DIR="/tmp/hyprlock_music_cache"

# Ensure placeholder exists
if [[ ! -f "$PLACEHOLDER" ]]; then
	magick -size 1x1 xc:transparent "$PLACEHOLDER"
fi

# Ensure cache directory exists
mkdir -p "$MUSIC_CACHE_DIR"

# Check if music is playing via playerctl first
STATUS=$(playerctl status 2>/dev/null)

# If playerctl doesn't return Playing, check MPD/rmpc
if [[ "$STATUS" != "Playing" ]]; then
	# Check MPD status via mpc
	MPD_STATUS=$(mpc status "%state%" 2>/dev/null)
	if [[ "$MPD_STATUS" == "playing" ]]; then
		USING_MPD=true
	else
		# No music playing
		if [[ "$1" == "--art" ]]; then
			echo "$PLACEHOLDER"
			exit 0
		elif [[ "$1" == "--time" ]]; then
			# Allow --time to proceed with defaults (PERC=0, TITLE="unknown")
			true
		else
			exit 0
		fi
	fi
fi

# Function to get MPD metadata
get_mpd_info() {
	local field="$1"
	case "$field" in
	"title")
		mpc -f "%title%" current 2>/dev/null
		;;
	"artist")
		local artist=$(mpc -f "%artist%" current 2>/dev/null)
		if [[ -z "$artist" ]]; then
			artist=$(mpc -f "%albumartist%" current 2>/dev/null)
		fi
		echo "$artist"
		;;
	"file")
		mpc -f "%file%" current 2>/dev/null
		;;
	"time")
		mpc status "%currenttime% %totaltime%" 2>/dev/null | tr ' ' '\n' | head -2
		;;
	"percent")
		mpc status "%percenttime%" 2>/dev/null | tr -d '%'
		;;
	esac
}

# Function to get current song identifier (for caching/seeding)
get_song_id() {
	if [[ "$USING_MPD" == true ]]; then
		mpc current "%file%" 2>/dev/null
	else
		playerctl metadata mpris:trackid 2>/dev/null || playerctl metadata title 2>/dev/null
	fi
}

# Function to extract album art from music file (atomic writes to avoid hyprlock reading partial PNGs)
extract_album_art() {
	local file_path="$1"
	local cache_file="$2"
	local tmp_file="${cache_file}.tmp.$$"

	# Try to extract embedded artwork using ffmpeg (atomic: write to tmp, then mv)
	if ffmpeg -y -i "$file_path" -an -vcodec copy -f image2pipe - 2>/dev/null | magick - "$tmp_file" 2>/dev/null && [[ -f "$tmp_file" && -s "$tmp_file" ]]; then
		mv "$tmp_file" "$cache_file"
		return 0
	fi
	rm -f "$tmp_file"

	if ffmpeg -y -i "$file_path" -an -vcodec png -f image2pipe - 2>/dev/null | magick - "$tmp_file" 2>/dev/null && [[ -f "$tmp_file" && -s "$tmp_file" ]]; then
		mv "$tmp_file" "$cache_file"
		return 0
	fi
	rm -f "$tmp_file"

	# Try to get cover from same directory
	local dir=$(dirname "$file_path")
	for cover in "$dir/cover.jpg" "$dir/cover.png" "$dir/folder.jpg" "$dir/folder.png" "$dir/album.jpg" "$dir/album.png" "$dir/art.jpg" "$dir/art.png"; do
		if [[ -f "$cover" ]]; then
			cp "$cover" "$tmp_file" && mv "$tmp_file" "$cache_file"
			return 0
		fi
	done
	return 1
}

# Truncate text with ellipsis, max 50 chars
truncate_text() {
	local text="$1"
	local max=50
	if [ ${#text} -gt $max ]; then
		echo "${text:0:47}..."
	else
		echo "$text"
	fi
}

if [[ "$1" == "--title" ]]; then
	if [[ "$USING_MPD" == true ]]; then
		truncate_text "$(get_mpd_info "title")"
	else
		truncate_text "$(playerctl metadata title)"
	fi

elif [[ "$1" == "--artist" ]]; then
	if [[ "$USING_MPD" == true ]]; then
		truncate_text "$(get_mpd_info "artist")"
	else
		truncate_text "$(playerctl metadata artist)"
	fi

elif [[ "$1" == "--art" ]]; then
	if [[ "$USING_MPD" == true ]]; then
		# Get the current file path
		MPD_FILE=$(get_mpd_info "file")
		if [[ -n "$MPD_FILE" ]]; then
			# Create a hash for caching
			HASH=$(echo -n "$MPD_FILE" | sha256sum | awk '{print $1}')
			CACHE_FILE="$MUSIC_CACHE_DIR/cover_$HASH.jpg"

			# Check if we already have this cached
			if [[ -f "$CACHE_FILE" ]]; then
				echo "$CACHE_FILE"
				exit 0
			fi

			# Find the actual file - check multiple common music library paths
			FULL_PATH=""
			for base in "$HOME/Music" "/mnt/media/Music" "/media/Music" "/srv/music"; do
				if [[ -f "$base/$MPD_FILE" ]]; then
					FULL_PATH="$base/$MPD_FILE"
					break
				fi
			done

			# Also check mpd.conf for music_directory
			if [[ -z "$FULL_PATH" && -f "$HOME/.config/mpd/mpd.conf" ]]; then
				MPD_MUSIC_DIR=$(grep "^music_directory" "$HOME/.config/mpd/mpd.conf" | sed 's/music_directory "//;s/"$//' | sed "s|~|$HOME|")
				if [[ -n "$MPD_MUSIC_DIR" && -f "$MPD_MUSIC_DIR/$MPD_FILE" ]]; then
					FULL_PATH="$MPD_MUSIC_DIR/$MPD_FILE"
				fi
			fi

			if [[ -n "$FULL_PATH" && -f "$FULL_PATH" ]]; then
				# Extract album art from the file
				if extract_album_art "$FULL_PATH" "$CACHE_FILE"; then
					echo "$CACHE_FILE"
					exit 0
				fi
			fi
		fi
		echo "$PLACEHOLDER"
	else
		# Original playerctl logic
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
				# Download atomically to avoid hyprlock reading partial file
				curl -s "$URL" -o "${CACHE_FILE}.tmp.$$" && mv "${CACHE_FILE}.tmp.$$" "$CACHE_FILE"
			fi
			echo "$CACHE_FILE"
		else
			echo "$PLACEHOLDER"
		fi
	fi

elif [[ "$1" == "--time" ]]; then
	# Optional: $2=width $3=height for per-monitor resolution
	FRAME_WIDTH="${2:-2560}"
	FRAME_HEIGHT="${3:-1440}"

	# Ensure we have defaults
	PERC=0
	TITLE="unknown"

	# Cache file for MPD position interpolation
	MPD_CACHE="/tmp/hyprlock_mpd_cache"
	NOW=$(date +%s.%N)

	if [[ "$USING_MPD" == true ]]; then
		# Get MPD time info
		TIME_INFO=$(get_mpd_info "time")
		POS_STR=$(echo "$TIME_INFO" | head -1)
		LEN_STR=$(echo "$TIME_INFO" | tail -1)

		# Parse time strings (MM:SS format) with defaults
		POS_SEC=0
		LEN_SEC=100
		if [[ "$POS_STR" =~ ^([0-9]+):([0-9]+)$ ]]; then
			POS_MIN=${BASH_REMATCH[1]}
			POS_SEC=${BASH_REMATCH[2]}
			POS_SEC=$((POS_MIN * 60 + POS_SEC))
		fi

		if [[ "$LEN_STR" =~ ^([0-9]+):([0-9]+)$ ]]; then
			LEN_MIN=${BASH_REMATCH[1]}
			LEN_SEC=${BASH_REMATCH[2]}
			LEN_SEC=$((LEN_MIN * 60 + LEN_SEC))
		fi

		# Sub-second interpolation for MPD
		# MPD only gives seconds, so we interpolate using system clock
		if [ "$LEN_SEC" -gt 0 ]; then
			# Read cached position and timestamp
			if [[ -f "$MPD_CACHE" ]]; then
				read -r LAST_POS LAST_TIME LAST_LEN <"$MPD_CACHE" 2>/dev/null || true
			fi

			# Check if this is a new song or continued playback
			if [[ -n "$LAST_LEN" && "$LAST_LEN" -eq "$LEN_SEC" && -n "$LAST_POS" && "$LAST_POS" -le "$POS_SEC" ]]; then
				# Same song - interpolate position
				ELAPSED=$(echo "$NOW - $LAST_TIME" | bc)
				# Cap interpolation to 1 second max (since MPD updates every second)
				if [[ $(echo "$ELAPSED > 1.0" | bc) -eq 1 ]]; then
					ELAPSED="1.0"
				fi
				POS_FLOAT=$(echo "$POS_SEC + $ELAPSED" | bc)
			else
				# New song or seeked
				POS_FLOAT=$POS_SEC
			fi

			# Write cache for next update
			echo "$POS_SEC $NOW $LEN_SEC" >"$MPD_CACHE"

			# Calculate percentage with float precision
			PERC=$(echo "scale=2; $POS_FLOAT * 100 / $LEN_SEC" | bc)
		fi

		# Get song title for seeding (fallback if empty)
		TITLE=$(get_mpd_info "title")
		[[ -z "$TITLE" ]] && TITLE="unknown"
	else
		# Original playerctl logic with error handling
		LENGTH=$(($(playerctl metadata mpris:length 2>/dev/null) - 10000000))
		POSITION=$(playerctl position 2>/dev/null)
		TITLE=$(playerctl metadata title 2>/dev/null)

		[[ -z "$TITLE" ]] && TITLE="unknown"

		if [[ -n "$LENGTH" && -n "$POSITION" && "$LENGTH" -gt 0 ]]; then
			# Convert to integer seconds
			LEN_SEC=$(echo "$LENGTH / 1000000" | bc)
			POS_SEC=${POSITION%.*}

			if [ "$LEN_SEC" -gt 0 ]; then
				# Calculate current percentage (0-100) with float precision
				PERC=$(echo "scale=2; $POS_SEC * 100 / $LEN_SEC" | bc)
			fi
		fi
	fi

	# Clamp PERC to 0-100 range (use bc for float comparison)
	if (($(echo "$PERC < 0" | bc -l))); then PERC=0; fi
	if (($(echo "$PERC > 100" | bc -l))); then PERC=100; fi

	# --- FULL SCREEN IMAGE ANIMATION ---

	# Use float percentage formatted to 2 decimals for accurate incrementing. Force LC_NUMERIC=C to prevent parsing errors due to locale comma/dot mismatches
	PERC_STR=$(LC_NUMERIC=C printf "%.2f" "$PERC")

	# Cache directory for frames (per-resolution)
	CACHE_DIR="/tmp/hyprlock_time_frames/${FRAME_WIDTH}x${FRAME_HEIGHT}"
	mkdir -p "$CACHE_DIR"

	# Generate hash for cache key
	SEED_STR="$TITLE:$PERC_STR"
	FRAME_HASH=$(echo "$SEED_STR" | sha256sum | cut -d' ' -f1 | cut -c1-16)
	FRAME_FILE="$CACHE_DIR/time_${FRAME_HASH}.png"

	# Return cached frame if exists
	if [[ -f "$FRAME_FILE" ]]; then
		echo "$FRAME_FILE"
		exit 0
	fi

	# Generate new frame using Python script
	SCRIPT_DIR="$(dirname "$0")"
	python3 "$SCRIPT_DIR/generate_time_frame.py" "$PERC_STR" "$TITLE" "$FRAME_FILE" "$FRAME_WIDTH" "$FRAME_HEIGHT" 2>/dev/null
fi
