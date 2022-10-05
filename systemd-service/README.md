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
