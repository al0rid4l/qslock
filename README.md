# qslock
Screen locker based on Quickshell

![Video](https://imgur.com/a/5qfXULo)

# Requirements

* Quickshell v0.3.0

# Usage

```bash
$ git clone --depth=1 https://github.com/al0rid4l/qslock.git .config/quickshell
$ qs -c qslock
```

Integration with swayidle
```ini
lock 'pidof qslock || bash -c "exec -a qslock qs -c qslock"'
before-sleep 'loginctl lock-session'
timeout 900 'loginctl lock-session'
timeout 1200 'niri msg action power-off-monitors' resume 'niri msg action power-on-monitors'
timeout 1800 'systemctl suspend'
idlehint 900
```

swayidle.service
```ini
[Unit]
Description=swayidle service
PartOf=graphical-session.target
After=graphical-session.target
[Install]
WantedBy=graphical-session.target
[Service]
Type=exec
ExecStart=/usr/bin/swayidle -w
TimeoutSec=5
```

# Configuration

All options can be found in [QSLockConfig.qml](./qslock/QSLockConfig.qml)