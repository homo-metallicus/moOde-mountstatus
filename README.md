# moOde-mountstatus

moOde-mounstatus is an experimental feature which consists in a set of systemd unit definition files, shell script and modified moOde UI source files to improve moOde player's auto remount capabilities and basic LED management.

Main script "mounstatus.sh" tries to remount moOde's sources automatically if they become unavailable and controls the behavior of the raspberry pi LEDs depending on their availability. \
It is called by a one shot systemd service unit triggered by a systemd timer unit every 15 seconds after the last execution.

Sources can be network shares (SMB, NFS, UPnP) or attached USB devices.

Red LED is off by default. \
Fixed green LED: all configured sources are available. \
Blinking green LED: at least one of the configured sources is unavailable. \
Blinking red LED: none of the configured sources are available.
