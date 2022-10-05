# moOde-mountstatus

moOde-mounstatus is an experimental feature which consists in a set of systemd unit definition files, shell script and modified moOde UI source files to improve moOde's player auto remount capabilities and basic LED management.

Main script "mounstatus.sh" queries moOde's local SQLite database to fetch sources' settings, tries to remount sources automatically if they become unavailable and controls the behavior of the rpi LEDs depending on their availability. \It is called by a one shot systemd service unit started by a systemd timer unit every 15 seconds after the last execution, you can change this timing to suite your needs.

Sources can be network shares (SMB, NFS, UPnP) or attached USB devices.

Red LED is off by default. \
Fixed green LED: all configured sources are available. \
Blinking green LED: at least one of the configured sources is unavailable. \
Blinking red LED: none of the configured sources are available.
