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

# systemd service

Place script "mounstatus.sh" in "/usr/local/sbin" and make it executable: \
sudo chmod +x /usr/local/sbin/mounstatus.sh

Place systemd service definition files "mounstatus.service" and "mounstatus.timer" in "/etc/systemd/system" and enable them: \
sudo systemctl enable mounstatus.service \
sudo systemctl enable mounstatus.timer

Reboot system: \
sudo shutdown -r now

Check the output of the script: \
tail -f /var/log/syslog \
or \
journalctl -u mountstatus.service

# moOde UI

moOde source files to integrate moOde-mountstatus feature to system configuration in moOde UI. \
moOde-mounstatus feature will disable moOde's basic LED management.

Place script "setupDB.sh" in "/usr/local/sbin", make it executable and execute it: \
sudo chmod +x /usr/local/sbin/setupDB.sh \
sudo /usr/local/sbin/setupDB.sh

Replace file "worker.php" in "/var/www/daemon" \
Relace file "sys-config.php" in "/var/www" \
Replace file "sys-config.html" in "/var/www/templates"
