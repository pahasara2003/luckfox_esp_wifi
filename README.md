# Luckfox Pico Mini B + ESP32-C3 SuperMini SPI Wi-Fi (ESP-Hosted)

- `dts/` device tree; copy to `luckfox-pico/sysdrv/source/kernel/arch/arm/boot/dts/` and build `rv1103g-luckfox-pico-mini-esp32.img`
  (needs SDK `sysdrv/tools/pc/uboot_tools` on PATH for `mkimage`).
- `patches/` changes on top of espressif/esp-hosted-linux at the commit in `esp-hosted-linux.commit`
  (`esp_luckfox_compat.c` goes in `host/`, apply `host-Makefile.patch`).
- Firmware: ESP-IDF v6.1, `idf.py set-target esp32c3 && idf.py build` in `esp/esp_driver/network_adapter`.
- ESP32-C3 wiring (SuperMini): CS IO10, SCLK IO6, MOSI IO7, MISO IO2, Handshake IO3, Data Ready IO4, reset RST/EN.
- Status: boot.img, esp32_spi.ko, C3 firmware and wpa_supplicant built (kernel 5.10.160); binaries in `bundle/` (gitignored). Nothing flashed or tested on hardware yet.
- Hardware steps: `bundle/flash_esp32c3.sh /dev/ttyACMx`; flash `boot.img` to the Luckfox; copy `bundle/` to the board and run `board_bringup.sh <ssid> <psk>`.
- wpa_supplicant comes from the SDK `project/app/wifi_app` (static libnl); the stock rootfs has none.
