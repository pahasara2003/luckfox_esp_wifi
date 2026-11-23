#!/bin/bash
# run.sh CLOCK_MHZ  -> reloads driver at that clock and measures
C=$1; B=root@172.32.0.93; W=192.168.1.2; PC=192.168.1.8
ssh $B "killall wpa_supplicant udhcpc 2>/dev/null; rmmod esp32_spi; sleep 1; dmesg -c >/dev/null; insmod /tmp/esp32_spi_test.ko spi_max_mhz=$C; /etc/init.d/S98esp32wifi start" 
for i in $(seq 40); do ssh $B 'ifconfig wlan0 2>/dev/null | grep -q "inet addr"' && break; sleep 2; done
sleep 3
echo "== clock $C: $(ssh $B 'dmesg | grep -E "Reconfigure SPI CLK|capping" | tail -1 | sed "s/.*esp32_spi: //"')"
ssh $B 'wpa_cli -i wlan0 signal_poll | head -1'
ssh $B "ping -c1 -W2 $PC >/dev/null"; ping -q -c 20 -i 0.3 $W | tail -1
ssh $B "python3 /tmp/tp.py recv 5002 > /tmp/down.txt" & sleep 2; python3 tp.py send $W 5002 10; wait; echo "download $(ssh $B cat /tmp/down.txt)"
python3 tp.py recv 5001 > up.txt & sleep 1; ssh $B "python3 /tmp/tp.py send $PC 5001 10 & sleep 5; top -bn1 | sed -n 2p; wait"; wait; echo "upload $(cat up.txt)"
