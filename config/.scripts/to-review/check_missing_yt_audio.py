import subprocess
import pathlib
import re

PLAYLIST_URL = "https://www.youtube.com/playlist?list=PLESFnlO3kNnoIak-yvbAkKIqISgPFVtWW"
LOCAL_DIR = pathlib.Path("~/Music/The Legend of Zelda (TLoZ)/Wind Waker/").expanduser()  # <-- CHANGE THIS

def normalize(name: str, yt=False) -> str:
    """
    Normalize names so yt titles and filenames match:
    - lowercase
    - replace spaces and symbols with _
    - collapse multiple _
    """
    name = name.lower()
    name = re.sub(r"[^\w]+", "_", name)
    name = re.sub(r"_+", "_", name).strip("_")
    if yt:
        name = name.replace("_na", "")  # yt-dlp adds this to avoid zero-width space issues
    return name

# --- Get playlist video titles via yt-dlp ---
result = subprocess.run(
    ["yt-dlp", "--flat-playlist", "--print", "%(creator)s - %(title).200B.%(ext)s", PLAYLIST_URL],
    capture_output=True,
    text=True,
    check=True
)

playlist_titles = [
    normalize(line, True)
    for line in result.stdout.splitlines()
    if line.strip()
]

# --- Get local opus filenames ---
local_files = [
    normalize(p.stem)
    for p in LOCAL_DIR.glob("*.opus")
]

playlist_set = set(playlist_titles)
local_set = set(local_files)

missing = sorted(playlist_set - local_set)

print(f"Playlist tracks: {len(playlist_set)}")
print(f"Local files:     {len(local_set)}")
print()

if missing:
    print("Missing tracks:")
    for name in missing:
        print(" -", name)
else:
    print("No tracks missing 🎉")

print(playlist_titles[:5])  # Print first few entries for verification
print("--")
print(local_files[:5])  # Print first few entries for verification
