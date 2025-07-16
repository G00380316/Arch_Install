
🔁 Fix: Delay start or auto-restart
If it’s a race condition, create or override the systemd unit:

## bash

systemctl --user edit pipewire-media-session

## Paste:

```
[Service]
Restart=on-failure
RestartSec=1
ExecStartPre=/bin/sleep 1
```

