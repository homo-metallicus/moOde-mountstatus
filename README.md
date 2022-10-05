# moOde-mountstatus

moOde-mounstatus is an experimental feature which consists in a set of systemd service definition files, shell script and modified moOde UI source files to improve moOde's audio player auto remount capabilities.

moOde-mounstatus also controls the behavior of the rpi LEDs depending on availability of configured sources.

Sources can be network shares (SMB, NFS, UPnP) or attached USB devices.

Main script "mounstatus.sh" is called by a one shot systemd service unit started by a systemd timer unit every 15 seconds after the last execution, you can change this timing to suite your needs. It queries the local SQLITE db to fetch sources' settings and tries to remount configured sources automatically if they become unavailable.

# LED behavior

Red LED off by default.

Fixed green LED: all configured sources are available. \
Blinking green LED: at least one of the configured sources is unavailable. \
Blinking red LED: none of the configured sources are available.
