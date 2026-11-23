#!/bin/sh
# Run ON the Luckfox after copying this folder to it (e.g. /tmp/b). Usage: ./board_bringup.sh <ssid> <psk>
set -e; cd "$(dirname "$0")"
insmod cfg80211.ko 2>/dev/null || true
insmod esp32_spi.ko
sleep 3; dmesg | tail -20
ifconfig wlan0 up || ip link set wlan0 up
printf 'ctrl_interface=/var/run/wpa_supplicant\nnetwork={\n ssid="%s"\n psk="%s"\n}\n' "$1" "$2" > /tmp/wpa.conf
chmod +x wpa_supplicant wpa_cli
./wpa_supplicant -B -i wlan0 -D nl80211 -c /tmp/wpa.conf
sleep 5; udhcpc -i wlan0; ifconfig wlan0
