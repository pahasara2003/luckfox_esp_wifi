# Luckfox Pico Mini B + ESP32-C3 SuperMini SPI Wi-Fi (ESP-Hosted)

**Build guide:** [ESP32C3 WiFi Driver for Luckfox Pico Mini](https://accidentalantenna.pages.dev/projects/luckfox-esp32-c3-spi-wifi/) on [AccidentalAntenna](https://accidentalantenna.pages.dev).

- `dts/` device tree; copy to `luckfox-pico/sysdrv/source/kernel/arch/arm/boot/dts/` and build `rv1103g-luckfox-pico-mini-esp32.img`
  (needs SDK `sysdrv/tools/pc/uboot_tools` on PATH for `mkimage`).
- `patches/` changes on top of espressif/esp-hosted-linux at the commit in `esp-hosted-linux.commit`
  Build the host module: `make target=spi LUCKFOX_COMPAT=y -C <sdk>/sysdrv/source/objs_kernel M=$PWD/esp-hosted-linux/host ARCH=arm CROSS_COMPILE=<sdk toolchain prefix> modules`, then `strip --strip-debug` (the board has only ~33 MB RAM; unstripped modules OOM it).
  (`esp_luckfox_compat.c` goes in `host/`, apply `host-Makefile.patch`).
- Firmware: ESP-IDF v6.1, `idf.py set-target esp32c3 && idf.py build` in `esp/esp_driver/network_adapter`.
- ESP32-C3 wiring (SuperMini): CS IO10, SCLK IO6, MOSI IO7, MISO IO2, Handshake IO3, Data Ready IO4, reset RST/EN.
- Status: boot.img, esp32_spi.ko, C3 firmware and wpa_supplicant built (kernel 5.10.160); binaries in `bundle/` (gitignored). Nothing flashed or tested on hardware yet.
- Hardware steps: `bundle/flash_esp32c3.sh /dev/ttyACMx`; flash `boot.img` to the Luckfox; copy `bundle/` to the board and run `board_bringup.sh <ssid> <psk>`.
- The Luckfox stock rootfs already has wpa_supplicant 2.6 (nl80211), wpa_cli, udhcpc, ifconfig, ip. Board reachable via USB RNDIS: host 172.32.0.100, `ssh root@172.32.0.93`. Boot partition is 4 MB. SPI0 (spi@ff500000) is disabled in the stock DT and uses spi0m0 pins (CS PC0, CLK PC1, MOSI PC2, MISO PC3) which match the DTS; spi2.0 is the on-board SPI NAND.
- Bring-up status (2026-11-23): WORKING up to scan. SPI mode 3 on both sides (firmware `g_spi_mode`, DTS `spi-cpha`); host driver clears bit 7 of RX byte 0 (first MISO bit reads 1; workaround, see patches/). Use the SDK-built `cfg80211.ko` (stock /oem one Oopses). Reset the ESP via USB/serial RTS after loading the driver (no reset wire). Scan found a 2.4 GHz network; not yet associated (needs credentials).
- Apply `patches/esp-hosted-linux.patch` to esp-hosted-linux (it includes the Makefile hook, SPI mode 3 firmware change, first-bit workaround; `esp_luckfox_compat.c` is in patches/ and goes in host/).

## Auto-start at boot
- `/oem/usr/ko/cfg80211.ko` replaced by the SDK build (stock kept as `cfg80211.ko.stock`); `esp32_spi.ko` copied to `/oem/usr/ko/`.
- `bundle/S98esp32wifi` → `/etc/init.d/`: loads the modules, waits for `wlan0`, runs `wpa_supplicant -c /etc/wpa_supplicant.conf` and `udhcpc`. Log: `/tmp/esp32wifi.log`.
- Reset: Luckfox pin 12 (GPIO1_D0) → ESP32-C3 GPIO1. Patched firmware latches the host's ~0.3 ms low pulse with a GPIO interrupt and restarts when the line goes high (SuperMini has no EN on the header). Polling missed the pulse.
- Wi-Fi network goes in `/etc/wpa_supplicant.conf` (chmod 600).

## Slimmed boot
`/oem/usr/ko/insmod_ko.sh` replaced by `bundle/insmod_ko.sh` (no-op; original kept on board as `insmod_ko.sh.stock`). Skips camera/ISP, NPU, video codec, audio, motor and stock-Wi-Fi (`rkwifi_server`, aic8800) modules. Result: 15.2 MB RAM available (was 11.5), load ~0.2 (was ~10), only `esp32_spi` + `cfg80211` loaded. `adbd` kept.

## Power
Power the ESP32-C3 SuperMini from Luckfox **VBUS (5V)** into the SuperMini **5V** pin. From the Luckfox 3V3 pin the ESP32 browns out when its radio starts: boot event arrives, then `cmd_init_interface` times out.

## Reachability
Firmware forces `WIFI_PS_NONE` even when the host asks for power save: in modem sleep the ESP32 missed broadcast ARP requests, so the board was unreachable over Wi-Fi until it sent traffic itself.
