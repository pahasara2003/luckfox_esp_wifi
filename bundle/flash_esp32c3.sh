#!/bin/sh
# Flash the ESP32-C3 SuperMini over its USB port (hold BOOT, tap RST if it isn't detected). Usage: ./flash_esp32c3.sh /dev/ttyACM0
cd "$(dirname "$0")/esp32c3-firmware" && esptool.py --chip esp32c3 -p "${1:?serial port}" -b 460800 write-flash --flash-mode dio --flash-size 4MB --flash-freq 80m \
  0x0 bootloader.bin 0x8000 partition-table.bin 0xd000 ota_data_initial.bin 0x10000 network_adapter.bin
