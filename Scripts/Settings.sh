#!/bin/bash

mv $GITHUB_WORKSPACE/patch/997-mac.sh package/base-files/files/etc/uci-defaults/997-mac.sh
mv $GITHUB_WORKSPACE/patch/10_system.js feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
IPQ_TARGET=$(grep -o 'CONFIG_TARGET_qualcommax_[^=]*' .config | sed -n 's/CONFIG_TARGET_qualcommax_//p' | head -n1)

rm -rf .vermagic
if grep -Eq "luci-app-(store|kwrt)=y" .config; then
    mv $GITHUB_WORKSPACE/vm/vikingyfy-istore vermagic
	mv $GITHUB_WORKSPACE/patch/998-istore.sh package/base-files/files/etc/uci-defaults/998-ipq.sh
else
    mv $GITHUB_WORKSPACE/vm/vikingyfy-$IPQ_TARGET vermagic
	mv $GITHUB_WORKSPACE/patch/998-$IPQ_TARGET.sh package/base-files/files/etc/uci-defaults/998-ipq.sh
fi

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang

rm -rf feeds/packages/net/{adguardhome,smartdns}
rm -rf feeds/luci/applications/{luci-app-adguardhome,luci-app-smartdns}
git clone --depth 1 https://github.com/kenzok8/small-package.git package/small-package
mv package/small-package/adguardhome package/adguardhome
mv package/small-package/luci-app-adguardhome package/luci-app-adguardhome
mv package/small-package/luci-app-easymesh package/luci-app-easymesh
mv package/small-package/luci-app-ikoolproxy package/luci-app-ikoolproxy
mv package/small-package/lucky package/lucky
mv package/small-package/luci-app-lucky package/luci-app-lucky
mv package/small-package/luci-app-pushbot package/luci-app-pushbot
mv package/small-package/wrtbwmon package/wrtbwmon
mv package/small-package/luci-app-wrtbwmon package/luci-app-wrtbwmon
rm -rf package/small-package

rm -rf feeds/packages/net/{mosdns,v2ray-geodata}
rm -rf feeds/luci/applications/{luci-app-openclash,luci-app-passwall,luci-app-ssr-plus,luci-app-mosdns}
git clone --depth 1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone --depth 1 https://github.com/vernesong/OpenClash.git  package/openclash
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall.git package/luci-app-passwall
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall2.git package/luci-app-passwall2
git clone --depth 1 https://github.com/nikkinikki-org/OpenWrt-momo.git package/OpenWrt-momo
git clone --depth 1 https://github.com/nikkinikki-org/OpenWrt-nikki.git package/OpenWrt-nikki

rm -rf feeds/packages/net/{open-app-filter}
git clone --depth 1 https://github.com/sbwml/luci-app-openlist2 package/openlist2

git clone --depth 1 -b main https://github.com/linkease/istore.git package/istore
git clone --depth 1 -b master https://github.com/linkease/nas-packages.git package/nas-packages
git clone --depth 1 -b main https://github.com/linkease/nas-packages-luci.git package/nas-luci
mv package/nas-packages/network/services/* package/nas-packages/
rm -rf package/nas-packages/network


sed -i '130d' include/kernel-defaults.mk
sed -i '130i\\tcp $(TOPDIR)/vermagic $(LINUX_DIR)/.vermagic' include/kernel-defaults.mk
sed -i '30d' package/kernel/linux/Makefile
sed -i '30i\  STAMP_BUILT:=$(STAMP_BUILT)_$(shell cat $(LINUX_DIR)/.vermagic)' package/kernel/linux/Makefile

if grep -q "openclash=y" .config; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    # Download clash_meta
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    # 下载 GeoIP 和 GeoSite
    # wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    # wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
else
    echo "⚪️ 未选择 luci-app-openclash"
fi


########################################################################################################################################
#修改默认主题
#sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/+ ' \/ ' : '') + (luciversion ||/:/g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
sed -i "s/%C/\/ Complied on $(date +"%Y.%m.%d")/g" package/base-files/files/usr/lib/os-release
sed -i "s/%C/\/ Complied on $(date +"%Y.%m.%d")/g" package/base-files/files/etc/openwrt_release
#sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WIFI_PW'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WIFI_PW'/g" $WIFI_UC
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
#echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
#if [ -n "$WRT_PACKAGE" ]; then
#	echo -e "$WRT_PACKAGE" >> ./.config
#fi

#高通平台调整
DTS_PATH="./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#开启sqm-nss插件
	#echo "CONFIG_PACKAGE_luci-app-sqm=y" >> ./.config
	echo "CONFIG_PACKAGE_sqm-scripts-nss=y" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	if [[ "${WRT_CONFIG,,}" == *"ipq50"* ]]; then
		echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
	else
		echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> ./.config
	fi
	#无WIFI配置调整Q6大小
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "qualcommax set up nowifi successfully!"
	fi
fi
