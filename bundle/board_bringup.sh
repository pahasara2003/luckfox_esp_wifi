#!/bin/sh
# Run ON the Luckfox (copy this folder to /tmp/b). Usage: ./board_bringup.sh <ssid> <psk>
# Needs the matching cfg80211.ko: the stock one in /oem/usr/ko crashes (Oops) with esp32_spi.
# Reset the ESP32-C3 (replug USB / reset button) right after esp32_spi loads: it sends its boot event once.
set -e; cd "$(dirname "$0")"
rmmod esp32_spi 2>/dev/null || true
rmmod cfg80211 2>/dev/null || true
insmod cfg80211.ko
insmod esp32_spi.ko
echo "reset the ESP32 now; waiting for wlan0"
for i in $(seq 1 30); do [ -d /sys/class/net/wlan0 ] && break; sleep 1; done
ifconfig wlan0 up
printf 'ctrl_interface=/var/run/wpa_supplicant\nnetwork={\n ssid="%s"\n psk="%s"\n}\n' "$1" "$2" > /tmp/wpa.conf
wpa_supplicant -B -i wlan0 -D nl80211 -c /tmp/wpa.conf
sleep 6; udhcpc -i wlan0 -n; ifconfig wlan0
