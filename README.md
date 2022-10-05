# moOde-mountstatus

moOde-mounstatus is an **experimental feature** which consists in a set of systemd unit definition files, shell script and modified moOde UI source files to improve moOde player's auto remount capabilities and basic LED management.

Main script "mounstatus.sh" checks moOde's sources' availability, tries to remount them automatically if they become unavailable and controls raspberry pi LEDs' operation accordingly. \
It is called by a one shot systemd service unit triggered by a systemd timer unit every 3 seconds.

Sources can be network shares (SMB, NFS) or any attached USB device. UPnP shares aren't supported anymore.

Red LED is off by default. \
**Fixed green LED**: all sources are available. \
**Blinking green LED**: at least one of the sources is unavailable. \
**Blinking red LED**: none of the sources are available.
