#!/bin/sh

sed -ri '/check_signature/s@^[^#]@#&@' /etc/opkg.conf
sed -i '/passwall/d' /etc/opkg/distfeeds.conf
sed -i '/nss/d' /etc/opkg/distfeeds.conf
sed -i '/sqm/d' /etc/opkg/distfeeds.conf
sed -i '/qualcommax/d' /etc/opkg/distfeeds.conf
echo > /etc/opkg/distfeeds.conf
sed -i '$a src/gz openwrt_core https://dl.openwrt.ai/releases/24.10/targets/qualcommax/ipq60xx/6.12.55' /etc/opkg/distfeeds.conf
sed -i '$a src/gz openwrt_base https://mirrors.pku.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/base' /etc/opkg/distfeeds.conf
sed -i '$a src/gz openwrt_luci https://mirrors.pku.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/luci' /etc/opkg/distfeeds.conf
sed -i '$a src/gz openwrt_packages https://mirrors.pku.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/packages' /etc/opkg/distfeeds.conf
sed -i '$a src/gz openwrt_routing https://mirrors.pku.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/routing' /etc/opkg/distfeeds.conf
sed -i '$a src/gz openwrt_telephony https://mirrors.pku.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/telephony' /etc/opkg/distfeeds.conf
echo > /etc/opkg/customfeeds.conf
sed -i '$a src/gz kiddin9 https://dl.openwrt.ai/releases/24.10/packages/aarch64_cortex-a53/kiddin9' /etc/opkg/customfeeds.conf


# 设置所有网口可访问网页终端
uci delete ttyd.@ttyd[0].interface

# 设置所有网口可连接 SSH
uci set dropbear.@dropbear[0].Interface=''

# wifi设置
#uci set wireless.default_radio0.ssid=WiFi-$(cat /sys/class/ieee80211/phy0/macaddress|awk -F ":" '{print $5""$6 }' | tr 'a-z' 'A-Z')-5G
uci set wireless.default_radio0.ssid=OpenWrt-5G
uci set wireless.radio0.txpower='20'
uci set wireless.default_radio1.ssid=OpenWrt-2.4G
uci set wireless.radio1.txpower='20'
uci commit wireless

uci commit
cp /etc/clash_meta /etc/openclash/core/clash_meta

#不用重启network，源码自带
exit 0
