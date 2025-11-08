#!/bin/sh
sed -ri '/check_signature/s@^[^#]@#&@' /etc/opkg.conf
sed -i '/passwall/d' /etc/apk/repositories.d/distfeeds.list
sed -i '/nss/d' /etc/apk/repositories.d/distfeeds.list
sed -i '/sqm/d' /etc/apk/repositories.d/distfeeds.list
sed -i '/qualcommax/d' /etc/apk/repositories.d/distfeeds.list
sed -i 's#downloads.immortalwrt.org#mirrors.pku.edu.cn/immortalwrt#g' /etc/apk/repositories.d/distfeeds.list
sed -i '$a https://mirrors.pku.edu.cn/immortalwrt/snapshots/targets/qualcommax/ipq60xx/kmods/6.12.55-1-c38aa8f9bb9d721d48fd93243f7f206b/packages.adb' /etc/apk/repositories.d/distfeeds.list
sed -i '$a https://mirrors.pku.edu.cn/immortalwrt/snapshots/targets/qualcommax/ipq60xx/packages/packages.adb' /etc/apk/repositories.d/distfeeds.list

# 设置所有网口可访问网页终端
uci delete ttyd.@ttyd[0].interface

# 设置所有网口可连接 SSH
uci set dropbear.@dropbear[0].Interface=''

# wifi设置
uci set wireless.default_radio0.ssid=WiFi-$(cat /sys/class/ieee80211/phy0/macaddress|awk -F ":" '{print $5""$6 }' | tr 'a-z' 'A-Z')-5G
uci set wireless.radio0.txpower='20'
uci set wireless.default_radio1.ssid=WiFi-$(cat /sys/class/ieee80211/phy0/macaddress|awk -F ":" '{print $5""$6 }' | tr 'a-z' 'A-Z')-2.4G
uci set wireless.radio1.txpower='20'
uci commit wireless

#uci set network.lan.ipaddr='192.168.1.1'
#uci set network.usbwan=interface
#uci set network.usbwan.proto='dhcp'
#uci set network.usbwan.device='eth0'
#uci add_list firewall.cfg03dc81.network='usbwan'
#uci commit network
uci commit
cp /etc/my-clash /etc/openclash/core/clash_meta
#不用重启network，源码自带
exit 0
