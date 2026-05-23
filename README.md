# dell-fan-control

Automatic fan speed control for Dell laptops running Linux. Uses the `i8k` kernel module to set fan speed based on **actual CPU core temperatures** read from `coretemp` hwmon sensors.

**Why not `i8kmon`?** The bundled `i8kmon` daemon reads the wrong temperature sensor (often a static or inaccurate value), rendering it useless on many Dell models. This project reads CPU core temps directly and works reliably.

---

## How it works

```
Boot → udev triggers → create-temp-symlinks → /dev/cpu_die_temp_* created
                                                      ↓
                           fan-control.service polls every 2s → i8kfan
```

1. **`cpu-temp-stable-path.rules`** — A single udev rule fires when the `coretemp` hwmon device appears.
2. **`create-temp-symlinks`** — Scans `/sys/devices/platform/coretemp.*/hwmon/` for `temp*_label` files matching `Core N` and creates stable symlinks at `/dev/cpu_die_temp_N` pointing to the corresponding `temp*_input` files.
3. **`fan-control.bash`** — A systemd service loops every 2 seconds, reads all available `/dev/cpu_die_temp_*` symlinks, computes the maximum temperature across all cores, and sets the fan speed accordingly.

This design adapts to any number of CPU cores and handles missing sensors gracefully.

---

## Temperature thresholds

| Max core temp | Fan speed | Description |
|---------------|-----------|-------------|
| &gt; 65°C     | 2 (high)  | Maximum cooling |
| &gt; 50°C     | 1 (low)   | Moderate cooling |
| ≤ 50°C        | 0 (off)   | Passive / silent |
| No sensors    | 2 (high)  | **Safety fallback** — fan runs at max if sensors can't be read |

---

## Requirements

- Linux with systemd
- Dell laptop compatible with the [`i8k` kernel module](https://www.dell.com/support/kbdoc/en-us/000177010/dell-latitude-5x80-7x80-bios-1-26-0-and-later-thermal-management-and-fan-control)
- `i8kutils` package (provides `/usr/bin/i8kfan`)
- `coretemp` hwmon driver (built into the kernel on x86)

---

## Installation

```bash
sudo ./install.sh
```

The installer does the following:

1. Installs `i8kutils` via `apt`
2. Ensures `i8k` is loaded at boot (`/etc/modules`)
3. Copies files to their destinations:

| Source | Destination |
|--------|-------------|
| `fan-control.bash` | `/usr/local/bin/` |
| `create-temp-symlinks` | `/usr/local/bin/` |
| `fan-control.service` | `/etc/systemd/system/` |
| `cpu-temp-stable-path.rules` | `/etc/udev/rules.d/` |

4. Reloads udev rules and triggers device detection
5. Enables and starts the `fan-control` systemd service

No configuration files needed — thresholds are in `fan-control.bash`.

---

## Verification

Check that CPU temperature symlinks were created:

```bash
ls -l /dev/cpu_die_temp_*
# Expected output:
# /dev/cpu_die_temp_0 -> /sys/devices/platform/coretemp.0/hwmon/hwmon*/tempN_input
# /dev/cpu_die_temp_1 -> ...
```

Check the service:

```bash
journalctl -u fan-control -f
# Should show: max_temp=42000 cores=4
#              FAN=0
```

---

## Files

| File | Purpose |
|------|---------|
| `fan-control.bash` | Main control loop — reads sensors, sets fan speed |
| `create-temp-symlinks` | udev helper — creates `/dev/cpu_die_temp_*` on boot |
| `cpu-temp-stable-path.rules` | udev rule — triggers symlink creation when coretemp appears |
| `fan-control.service` | systemd unit — runs the control script with auto-restart |
| `install.sh` | One-command installer |
| `LICENSE` | Apache 2.0 |

---

## References

Research and sources that informed this project:

- [How to solve Dell laptop fan issues in Linux](http://keenformatics.blogspot.com/2013/06/how-to-solve-dell-laptops-fan-issues-in.html)
- [i8kutils issue: i8kmon reads wrong temperature](https://github.com/vitorafsr/i8kutils/issues/25)
- [Fan speed control (Arch Wiki)](https://wiki.archlinux.org/title/fan_speed_control)
- [i8kutils comment: systemd service approach](https://github.com/vitorafsr/i8kutils/issues/25#issuecomment-1097806307)
- [Stable device path for Linux hwmon interfaces](https://joonas.fi/2021/07/stable-device-path-for-linux-hwmon-interfaces/)
- [udev rule not creating symlink — need `add|change`](https://unix.stackexchange.com/a/714019)
