# Luckfox Pico Mini B + ESP32-C3 SuperMini SPI Wi-Fi (ESP-Hosted)

- `dts/` device tree; copy to `luckfox-pico/sysdrv/source/kernel/arch/arm/boot/dts/` and build `rv1103g-luckfox-pico-mini-esp32.img`
  (needs SDK `sysdrv/tools/pc/uboot_tools` on PATH for `mkimage`).
- `patches/` changes on top of espressif/esp-hosted-linux at the commit in `esp-hosted-linux.commit`
  (`esp_luckfox_compat.c` goes in `host/`, apply `host-Makefile.patch`).
- Firmware: ESP-IDF v6.1, `idf.py set-target esp32c3 && idf.py build` in `esp/esp_driver/network_adapter`.
- ESP32-C3 wiring (SuperMini): CS IO10, SCLK IO6, MOSI IO7, MISO IO2, Handshake IO3, Data Ready IO4, reset RST/EN.
- Status: boot.img, esp32_spi.ko, C3 firmware and wpa_supplicant built (kernel 5.10.160); binaries in `bundle/` (gitignored). Nothing flashed or tested on hardware yet.
- Hardware steps: `bundle/flash_esp32c3.sh /dev/ttyACMx`; flash `boot.img` to the Luckfox; copy `bundle/` to the board and run `board_bringup.sh <ssid> <psk>`.
- The Luckfox stock rootfs already has wpa_supplicant 2.6 (nl80211), wpa_cli, udhcpc, ifconfig, ip. Board reachable via USB RNDIS: host 172.32.0.100, `ssh root@172.32.0.93`. Boot partition is 4 MB. SPI0 (spi@ff500000) is disabled in the stock DT and uses spi0m0 pins (CS PC0, CLK PC1, MOSI PC2, MISO PC3) which match the DTS; spi2.0 is the on-board SPI NAND.
