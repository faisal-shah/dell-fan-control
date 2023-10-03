# Here's the research

## dell fan control sensor kernel module
http://keenformatics.blogspot.com/2013/06/how-to-solve-dell-laptops-fan-issues-in.html
## [ignore] modify /etc/i8kmon.conf
https://github.com/vitorafsr/i8kutils/issues/25
## [ignore] seems that ik8mon is useless cuz it reads the wrong temp, try this
https://wiki.archlinux.org/title/fan_speed_control
## Ended up creating a systemd service - cputempctrl.service according to this:
https://github.com/vitorafsr/i8kutils/issues/25#issuecomment-1097806307
## Need a stable device path
https://joonas.fi/2021/07/stable-device-path-for-linux-hwmon-interfaces/
Wasn't creating a symlink, had to change ACTION to add|change:
https://unix.stackexchange.com/a/714019
