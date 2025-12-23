# Arch Linux Installation and Setup

> This note documents the installation of Arch Linux according to my preferences with configuration.
> It assumes an existing Arch Linux installation for "## Flash USB" (with hints for other OS) and generally a good internet connection.

## Flash USB

See [archlinux.org/download/](https://archlinux.org/download/) for installation methods.
These steps are performed on an existing system.

Download `archlinux-YYYY.MM.DD-x86_64.iso`:
- Download using recommended method at "BitTorrent Download (recommended) > Magnet link for YYYY.MM.DD" section with "Magnet link" and the `qbittorrent` package.
- Or get pre-downloaded file from `@raspberrypi:~/data` or `~/drive/data`.

Download `archlinux-YYYY.MM.DD-x86_64.iso.sig`:
- Download from "HTTP Direct Downloads > Checksums and signatures > ISO > PGP signature" section.
- Or get pre-downloaded file from `@raspberrypi:~/data` or `~/drive/data`.

Verify ISO with `pacman-key -v archlinux-YYYY.MM.DD-x86_64.iso.sig`.
- See at "HTTP Direct Downloads > Checksums and signatures > Download verification" for other verification methods.

Flash USB stick:
1. Find out the name of your USB drive with `ls -l /dev/disk/by-id/usb-*`.
2. Check with `lsblk` to make sure that it is *not mounted*.
3. Flash with `cat path/to/archlinux-YYYY.MM.DD-x86_64.iso > /dev/disk/by-id/usb-My_flash_drive`.
    - Replace both `path/to/archlinux-YYYY.MM.DD-x86_64.iso` and `/dev/disk/by-id/usb-My_flash_drive` accordingly.

## Installation with USB

Insert and select USB stick in BIOS or change boot order so USB is first.
Perform this step on the target system with a wired keyboard.

1. Run `loadkeys de` (assuming that a German QWERTZ keyboard is used).
2. Run `cat /sys/firmware/efi/fw_platform_size` which should output `64`
    - Verifies UEFI boot mode
3. Unless using LAN, run `iwctl` to start connecting to Wi-Fi.
    1. Run `station wlan0 scan`.
    2. Run `station wlan0 get-networks` which outputs networks names.
    3. Run `station wlan0 connect "YOUR_NETWORK_NAME"`.
        - Replace `YOUR_NETWORK_NAME` with your selected network name.
    4. Run `exit`.
4. Run `ping -c 3 archlinux.org` or similar to check for working internet connection.
5. Run `timedatectl set-ntp true` to update system clock.
6. Run `fdisk -l` to identify target disk for partitioning. In the following, we use `/deb/sda` as an example.
7. Run `cfdisk /dev/sda`.
    - We partition `/dev/sda/` as follows:
        - 2 GB for "EFI system" at `/dev/sda1`
        - Remaining space for "Linux filesystem" at `/dev/sda2`
    - Use intuitive `cfdisk` TUI to partition the disk accordingly.
8. Format partitions:
    1. Run `mkfs.fat -F32 /dev/sda1`.
    2. Run `mkfs.ext4 /dev/sda2`.
9. Mount partitions:
    1. Run `mount /dev/sda2 /mnt`.
    2. Run `mkdir -p /mnt/boot` and `mount /dev/sda1 /mnt/boot`.
10. Install base system with `pacstrap -K /mnt base linux linux-firmware base-devel intel-ucode networkmanager nvim zsh git`
    - An NVIDIA package should not be necessary to get to TTY.
    - Possibly, also install `hyprland kitty firefox` and the correct NVIDIA driver (or other GPU driver), e.g. `nvidia-open` or `nvidia-580xx-dkms`.
11. Run `genfstab -U /mnt >> /mnt/etc/fstab`
    - Check contents with `cat /mnt/etc/fstab`.
12. Run `arch-chroot /mnt`.
13. Run `ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime` and `hwclock --systohc`.
    - Check for available options with `ls /usr/share/zoneinfo/`.
14. Configure localization:
    1. Edit with `nvim /etc/locale.gen`: Uncomment `en_US.UTF-8 UTF-8` and `de_DE.UTF-8 UTF-8`.
    2. Run `locale-gen`.
    3. Edit with `nvim /etc/locale.conf`:
       ```plain
       LANG=en_US.UTF-8
       LC_ADDRESS=de_DE.UTF-8
       LC_IDENTIFICATION=de_DE.UTF-8
       LC_MEASUREMENT=de_DE.UTF-8
       LC_MONETARY=de_DE.UTF-8
       LC_NAME=de_DE.UTF-8
       LC_NUMERIC=de_DE.UTF-8
       LC_PAPER=de_DE.UTF-8
       LC_TELEPHONE=de_DE.UTF-8
       LC_TIME=de_DE.UTF-8
       ```
15. Set hostname with `echo "myhostname" > /etc/hostname`.
16. Add hosts with `nvim /etc/hosts`:
    ```plain
    127.0.0.1    localhost
    ::1          localhost
    127.0.1.1    myhostname.localdomain    myhostname
    ```
17. Run `systemctl enable NetworkManager`.
18. Set root password with `passwd`.
19. Install and configure bootloader:
    1. Run `bootctl install`.
    2. Edit with `nvim /boot/loader/loader.conf`:
       ```plain
       default arch.conf
       timeout 3
       console-mode max
       editor no
       ```
    3. Find out root partition `your-partuuid` with `blkid /dev/sda2`.
    4. Edit with `nvim /boot/loader/entries/arch.conf`:
       ```plain
       title   Arch Linux
       linux   /vmlinuz-linux
       initrd  /intel-ucode.img
       initrd  /initramfs-linux.img
       options root=PARTUUID=your-partuuid-here rw
       ```
20. Add user:
    1. Run `useradd -m -G wheel -s /bin/zsh henrikmoellmann`.
    2. Set password with `passwd henrikmoellmann`.
    3. Enable sudo with `EDITOR=nvim visudo` and uncomment `%wheel ALL=(ALL:ALL) ALL`.
21. Configure NVIDIA (only if already installed NVIDIA driver):
    1. Configure early loading with `nvim /etc/mkinitcpio.conf`, find line with `MODULES=()`, and edit to:
       ```plain
       MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
       ```
    2. Regenerate initramfs with `mkinitcpio`.
    3. Add kernel parameter with `nvim /boot/loader/entries/arch.conf` and add:
       ```plain
       options root=PARTUUID=your-partuuid-here rw nvidia-drm.modeset=1
       ```
    4. Add pacman hook:
        1. Run `mkdir -p /etc/pacman.d/hooks`.
        2. Edit with `nvim /etc/pacman.d/hooks/nvidia.hook`:
           ```plain
           [Trigger]
           Operation=Install
           Operation=Upgrade
           Operation=Remove
           Type=Package
           Target=nvidia
           Target=linux

           [Action]
           Description=Update NVIDIA module in initcpio
           Depends=mkinitcpio
           When=PostTransaction
           NeedsTargets
           Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
           ```
22. Run `exit`.
23. Run `umount -R /mnt`.
24. Run `shutdown -h 0` and wait until target system is shut down, then remove USB.

## Configuration

1. If no internet connection using Wi-Fi:
    1. Run `nmtui` and configure Wi-Fi.
2. Set TTY language with `sudo nvim /etc/vconsole.conf`:
    ```plain
    KEYMAP=de
    ```
1. Enable Multilib for 32-bit support with `sudo nvim /etc/pacman.conf` and uncomment:
   ```plain
   [multilib]
   Include = /etc/pacman.d/mirrorlist
   ```
2. Install Yay as AUR helper:
    1. Run `cd /tmp`.
    2. Run `git clone https://aur.archlinux.org/yay.git`.
    3. Run `cd yay`.
    4. Run `makepkg -si`.
3. Add dotfiles, configuration, and packages:
    1. Run `git clone https://github.com/moellh/.dotfiles.git ~/.dotfiles`.
    2. Run `cd ~/.dotfiles`.
    3. Run `git remote set-url origin git@github.com:moellh/.dotfiles.git`.
    4. Add configuration with `stow config -t ~`.
        - NOTE: This may cause errors if files already exist in ~. Then, remove them and try again. Also, adapt this manual accordingly.
    5. Install packages with `cut -d',' -f1 packages.txt | xargs yay -S --`.
4. Unless already done, start `hyprland`.
5. Run `ssh-keygen` and follow instructions.
5. Run `gpg --full-generate-key` and follow instructions.
    - Run `gpg --armor --export my@mail.com | wl-copy` to copy the public key of GPG key with "my@mail.com".
6. Open `firefox` with `SUPER+f`:
    1. Open Google and login.
    2. Open Google Drive:
        1. Download `data/rclone.conf`.
        2. Run `mkdir ~/.config/rclone/` and move `rclone.conf` to the folder.
        3. Run `mkdir -p ~/drive`.
        4. Run `touch ~/drive/.RCLONE_TEST`.
        5. Run `cloudsync --resync` to sync files from Google Drive.
        6. Open `keepassxc` and login as needed.
    3. Login to Mozilla account in Firefox.
        1. Add pinned tabs.
    4. Login to GitHub:
        1. Add ssh key and gpg key
7. Install NVIM plugins:
    1. Run `nvim` and everything should install itself.
8. Install TMUX plugins:
    1. Type `SUPER+q` to start kitty with TMUX.
    2. Type `CTRL+b`, then `I` to install TMUX plugins with TPM.
9. Setup systemd services:
    - Run `sudo systemctl enable --now bluetooth.service`.
        - Connect Glove80, Galaxy Buds, etc. as needed.
    - Run `sudo systemctl enable --now vpnagentd`.
    - Run `systemctl --user enable --now syncthing.service`.
    - Run `systemctl --user enable --now dolphin-fix-open-with.service`.
    - Run `systemctl --user enable --now sync-google-drive-rclone.timer`.
    - TODO: `systemctl --user enable --now pipewire-pulse.service` if not enabled already
10. Login to moellh@raspberrypi:
    1. Run `ssh-copy-id moellh@raspberrypi` to copy public key to @raspberrypi using password.
11. Open `* syncthing` in Firefox and setup all Syncthing folders with @raspberrypi and e.g. phone.
