# moOde-mountstatus

The mounstatus feature consists in a set of systemd service definition files, shell script and modified moOde UI source files to improve moOde's audio player auto remount capabilities.
It also controls the behavior of the rpi LEDs depending on availability of configured sources and/or attached USB device(s).

Main script is called by a one shot systemd service unit started by a systemd timer unit every 15 seconds after the last execution, you can change this timing to suite your needs. It queries the local SQLITE db to fetch sources' settings and tries to remount configured sources automatically if they become unavailable.

Works with Samba, NFS, UPnP shares and attached USB device(s).

# LED behavior

Red LED off by default.

Fixed green LED: configured source(s) and/or attached USB device(s) available. \
Blinking green LED: at least one of the configured sources and/or attached USB device(s) unavailable. \
Fixed red LED: configured source(s) and/or attached USB device(s) unavailable.

# Install systemd service

Place script "mounstatus.sh" in "/usr/local/sbin" and make it executable: \
sudo chmod +x /usr/local/sbin/mounstatus.sh

Place systemd service definition files "mounstatus.service" and "mounstatus.timer" in "/etc/systemd/system" and enable them to launch at startup: \
sudo systemctl enable mounstatus.service \
sudo systemctl enable mounstatus.timer

Reboot system

Check the output of the script: \
tail -f /var/log/syslog

# moOde UI integration

Place script "setupDB.sh" in "/usr/local/sbin", make it executable and execute it: \
sudo chmod +x /usr/local/sbin/setupDB.sh \
sudo /usr/local/sbin/setupDB.sh

Replace file "worker.php" in "/var/www/daemon" \
Relace file "sys-config.php" in "/var/www" \
Replace file "sys-config.html" in "/var/www/templates"
