#!/usr/bin/env bash
# Install the system config from this folder onto the machine: files under etc/ go to
# /etc, and the units in services.txt get enabled. Shows a diff for every file that
# differs and asks before each change; replaced files are kept as <file>.bak-<date>.
#
# usage: system/install.sh            go through everything
#        system/install.sh --check    only report what differs (needs no sudo)
#
# Files ending in .template (the boot entry) are machine-specific: fill them in by hand.
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"
check_only=false
[[ ${1:-} == --check ]] && check_only=true
stamp=$(date +%Y%m%d-%H%M%S)
changed=()

# Reads the answer from the terminal: stdin of the loops below is their file/unit list.
ask() {
    local reply
    read -r -p "$1 [y/N] " reply </dev/tty
    [[ $reply =~ ^[yY] ]]
}

echo "== Files"
while IFS= read -r src; do
    dst=/${src#./}
    if [[ -f $dst && -r $dst ]] && cmp -s "$src" "$dst"; then
        continue
    fi
    if [[ -f $dst && ! -r $dst ]]; then
        echo "$dst: not readable without root, compare it by hand"
        continue
    fi
    if [[ ! -f $dst ]]; then
        echo "$dst: missing"
    else
        echo "$dst: differs"
        diff -u "$dst" "$src" || true
    fi
    $check_only && continue
    if ask "Install $dst?"; then
        [[ -f $dst ]] && sudo cp -a "$dst" "$dst.bak-$stamp"
        sudo install -D -m 644 "$src" "$dst"
        changed+=("$dst")
    fi
done < <(find etc -type f ! -name '*.template' | sort)

for template in $(find . -name '*.template' | sort); do
    target=/${template#./}
    echo "${target%.template}: machine-specific, fill it in by hand from system/${template#./}"
done

echo
echo "== Services"
section=
while IFS= read -r line; do
    line=${line%%#*}
    line=${line//[[:space:]]/}
    [[ -z $line ]] && continue
    if [[ $line =~ ^\[(system|user)\]$ ]]; then
        section=${BASH_REMATCH[1]}
        continue
    fi
    if [[ $section == user ]]; then
        state=$(systemctl --user is-enabled "$line" 2>/dev/null || true)
    else
        state=$(systemctl is-enabled "$line" 2>/dev/null || true)
    fi
    [[ $state == enabled ]] && continue
    echo "$line ($section): ${state:-not found}"
    $check_only && continue
    [[ $state == "" || $state == not-found ]] && continue
    if ask "Enable and start $line?"; then
        if [[ $section == user ]]; then
            systemctl --user enable --now "$line"
        else
            sudo systemctl enable --now "$line"
        fi
    fi
done < services.txt

if ((${#changed[@]} > 0)); then
    echo
    echo "== Follow-up for the installed files"
    for dst in "${changed[@]}"; do
        case $dst in
            /etc/mkinitcpio.conf) echo "- mkinitcpio.conf: run 'sudo mkinitcpio -P'; delete /etc/mkinitcpio.conf.pacnew" ;;
            /etc/locale.gen) echo "- locale.gen: run 'sudo locale-gen'" ;;
            /etc/UPower/UPower.conf) echo "- UPower.conf: run 'sudo systemctl restart upower'" ;;
            /etc/docker/daemon.json) echo "- daemon.json: run 'sudo systemctl restart docker'" ;;
            /etc/vconsole.conf) echo "- vconsole.conf: takes effect after 'sudo mkinitcpio -P' and a reboot" ;;
            /etc/pacman.conf) echo "- pacman.conf: run 'sudo pacman -Sy' (repos may have changed); delete /etc/pacman.conf.pacnew" ;;
        esac
    done
fi
