#!/bin/bash
#
# mountstatus.sh (C) 2022 @homo_metallicus (Romain DECLE)
# https://github.com/homo-metallicus/moOde-mountstatus
#
# This Program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This Program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

SQLDB=/var/local/www/db/moode-sqlite3.db
NUMSOURCES=$(sqlite3 ${SQLDB} "SELECT COUNT(1) FROM cfg_source")
declare -A STATUS
s=0

# checkRendererStatus() {
# 	BTstatus=$(echo -e "info $MAC\nquit" | bluetoothctl | grep Connected | tr -d " " | cut -d ":" -f2)
# 	if [[ ! -z $BTstatus ]] && [[ $BTstatus == "yes" ]]; then
# 		echo 1
# 	else
# 		echo 0
# 	fi
# }

disableLeds() {
	sqlite3 ${1} ".header off"
	LED_STATE=$(sqlite3 ${1} "SELECT value FROM cfg_system WHERE param LIKE 'led_state'")
	if [[ ${LED_STATE}!='0,0' ]]; then
		sqlite3 ${1} "UPDATE cfg_system SET value='0,0' WHERE param like 'led_state'"
		if [[ $(sqlite3 ${1} "SELECT value FROM cfg_system WHERE param LIKE 'led_state'")=='0,0' ]]; then
			echo "leds have been disabled by script"
		fi
	fi
}

switchLED() {
	case "${1}" in
		"green") LED=0;;
		"red") LED=1;;
	esac
	echo "${2}" > /sys/class/leds/led${LED}/trigger
}

checkMount() {
	timeout -k 2s -s KILL 1s /bin/mountpoint -q "${1}"
	echo $?
}

checkLocalMount() {
	/usr/bin/mount | /bin/grep -q "${1}"
	if [ $? -eq 0 ]; then
		NUMSOURCES=$(($NUMSOURCES + 1))
		_MOUNTPOINT=$(findmnt -o TARGET -n "${1}")
		DEVNAME=$(basename "${_MOUNTPOINT}")
		if [[ $(checkMount "${_MOUNTPOINT}") -eq 0 ]]; then
			status="available"
			s=$(($s + 1))
		else
			/usr/bin/umount "${_MOUNTPOINT}" || /usr/bin/umount -l "${_MOUNTPOINT}"
			status="unavailable"
		fi
		STATUS+=(["${DEVNAME} (USB)"]="${status}")
	fi
}

getColumnNames() {
	sqlite3 ${1} ".header off"
	local _COLUMNS=$(while read NAME; do echo "${NAME}" ; done <<< $(sqlite3 ${1} "SELECT name FROM pragma_table_info('${2}');"))
	echo "${_COLUMNS[@]}"
}

mountShare() {
	if [ ! -d "${5}" ]; then
		mkdir -p "${5}"
	fi
	if [ "${1}" == "cifs" ]; then
		SERVER="//${3}"
	fi
	if [ "${1}" == "nfs" ]; then
		SERVER="${3}:"
	fi
	/usr/bin/mount -t "${1}" -o "${2}" "${SERVER}/${4}" "${5}" > /dev/null 2>&1
	echo $?
}

disableLeds ${SQLDB}

if [ $(ls /sys/class/leds | grep led1) ]; then # Rpi-zero
	switchLED "red" "none"
fi

echo "---"

if [[ -f ${SQLDB} && ${NUMSOURCES} -gt 0 ]]; then
	while read SOURCE; do
		declare -a COLUMNS=$(getColumnNames ${SQLDB} "cfg_source")
		IFS='|' read -r -a SOURCES <<< "${SOURCE}"
		declare -A SCHEMA
		i=0
		for column in ${COLUMNS[@]}; do SCHEMA+=([${column}]="${SOURCES[$i]}") ; i=$(($i + 1)) ; done
		for varname in "${!SCHEMA[@]}"; do declare "${varname^^}"="${SCHEMA[$varname]}" ; done
		# if [ "${TYPE}" == "upnp" ]; then
		# 	MOUNTPOINT="/mnt/UPNP"
		# 	if [ $(checkMount "${MOUNTPOINT}") -ne 0 ]; then
		# 		switchLED "green" "heartbeat"
		# 		MOUNTOPTIONS="allow_other,nonempty,iocharset=utf-8"
		# 		lsmod | grep -wq fuse
		# 		if [ $? -ne 0 ]; then
		# 			modprobe fuse
		# 		fi
		# 		/usr/bin/mount | grep -wq "${MOUNTPOINT}"
		# 		if [ $? -eq 0 ]; then
		# 			fusermount -u "${MOUNTPOINT}"
		# 		fi
		# 		su -c "sudo djmount -o ${MOUNTOPTIONS} ${MOUNTPOINT} > /dev/null 2>&1" pi				
		# 		u=5
		# 		until [[ $(checkMount "${MOUNTPOINT}") -eq 0 ]]; do
		# 			sleep 1
		# 			if [ ${u} -eq 0 ]; then
		# 				if [ -e "/var/lib/mpd/music/${NAME}" ]; then
		# 					rm "/var/lib/mpd/music/${NAME}"
		# 				fi
		# 				break
		# 			fi
		# 			u=$(($u - 1))
		# 		done
		# 	fi
		# 	sleep 1
		# 	if [ $(checkMount "${MOUNTPOINT}") -eq 0 ]; then
		# 		if [ -e "${MOUNTPOINT}/${ADDRESS}/${REMOTEDIR}" ]; then
		# 			if [ ! -e "/var/lib/mpd/music/${NAME}" ]; then
		# 				switchLED "green" "heartbeat"
		# 				ln -s "${MOUNTPOINT}/${ADDRESS}/${REMOTEDIR}" "/var/lib/mpd/music/${NAME}"					
		# 				if [ $? -eq 0 ]; then
		# 					status="available"
		# 					s=$(($s + 1))
		# 				else
		# 					status="unavailable"
		# 				fi
		# 			else
		# 				status="available"
		# 				s=$(($s + 1))
		# 			fi
		# 		else
		# 			status="unavailable"
		# 			rm "/var/lib/mpd/music/${NAME}" > /dev/null 2>&1
		# 		fi
		# 	else
		# 		status="unavailable"
		# 	fi
		# else
			MOUNTPOINT="/mnt/NAS/${NAME}"
			if [ $(checkMount "${MOUNTPOINT}") -ne 0 ]; then
				# switchLED "green" "heartbeat"
				case "${TYPE}" in
					"cifs") MOUNTOPTIONS="user=${USERNAME},password=${PASSWORD},${OPTIONS},iocharset=${CHARSET},rsize=${RSIZE},wsize=${WSIZE}"
					cmdopt=( -l )
					;;
					"nfs") MOUNTOPTIONS="soft,timeo=10,retrans=1,${OPTIONS},rsize=${RSIZE},wsize=${WSIZE}"
					cmdopt=( -f )
					;;
				esac
				/usr/bin/mount | grep -wq "${MOUNTPOINT}"				
				if [ $? -eq 0 ]; then
					/usr/bin/umount "${cmdopt[@]}" "${MOUNTPOINT}"
				fi
				if [ $(mountShare "${TYPE}" "${MOUNTOPTIONS}" "${ADDRESS}" "${REMOTEDIR}" "${MOUNTPOINT}") -eq 0 ]; then
					status="available"
					s=$(($s + 1))
				else
					status="unavailable"
				fi
			else
				status="available"
				s=$(($s + 1))
			fi
		# fi
		STATUS+=(["${NAME} (${TYPE^^})"]="${status}")
	done <<< $(sqlite3 ${SQLDB} "SELECT * FROM cfg_source")
fi

declare -a _diskparts

# lsblk -Minplo MOUNTPOINT | grep /media | while read MOUNTPOINT; do
# 	__DEV=$(findmnt -o SOURCE -n "${MOUNTPOINT}")
# 	_DEV=$(lsblk -ndo pkname "${__DEV}")
# 	_device="/sys/block/"${_DEV}"/device"
# 	if echo $(readlink -f "$_device") | egrep -q "usb"; then		
# 		DEV=$(echo "$_device" | cut -f4 -d/)
# 		mount | grep "${DEV}" | grep -q media
# 		if [ $? -eq 0 ]; then
# 			_diskparts=$(while read BLOCKDEV ; do
# 				echo "${BLOCKDEV}"
# 			done <<< $(/usr/bin/mount | grep ${DEV} | grep media | cut -d" " -f1))
# 			for d in "${_diskparts}"; do
# 				checkLocalMount "${d}"
# 			done
# 		else
# 			NUMSOURCES=$(($NUMSOURCES + 1))
# 			status="unavailable"
# 			STATUS+=(["${DEV} (USB)"]="${status}")
# 		fi
# 	fi
# done

for _device in /sys/block/*/device; do
	if echo $(readlink -f "$_device") | egrep -q "usb"; then
		DEV=$(echo "$_device" | cut -f4 -d/)
		mount | grep "${DEV}" | grep -q media
		if [ $? -eq 0 ]; then
			_diskparts=$(while read BLOCKDEV ; do
				echo "${BLOCKDEV}"
			done <<< $(/usr/bin/mount | grep ${DEV} | grep media | cut -d" " -f1))
			for d in "${_diskparts}"; do
				checkLocalMount "${d}"
			done
		fi
	fi
done

if [ ${s} -eq 0 ]; then
	switchLED "green" "none"
	if [ $(ls /sys/class/leds | grep led1) ]; then # Rpi-zero
		switchLED "red" "heartbeat"
	fi
else
	for source in "${!STATUS[@]}"; do echo "${source}: ${STATUS[$source]}"; done
	if [ ${s} -eq ${NUMSOURCES} ]; then
		switchLED "green" "default-on"
	else
		switchLED "green" "heartbeat"
	fi
fi

echo "available: ${s}/${NUMSOURCES}"
echo "---"

exit 0
