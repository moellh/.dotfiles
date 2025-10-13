## Install Arch Linux

## Systemd Services

> I would recommend restarting the computer after enabling the services.

### System services

- `sudo systemctl enable bluetooth.service`

### User services

1. `systemctl --user daemon-reload` to reload files
2. `systemctl --user enable dolphin-fix-open-with.service` fixes Dolphin "Open With" menu
3. `systemctl --user enable sync-google-drive-rclone.timer` automatically syncs the local folder `~/drive` with my Google Drive
