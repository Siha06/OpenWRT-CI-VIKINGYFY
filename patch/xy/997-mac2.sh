#!/bin/sh
uci del dhcp.lan.ra
uci del dhcp.lan.ra_default
uci del dhcp.lan.ra_flags
uci del dhcp.lan.max_preferred_lifetime
uci del dhcp.lan.max_valid_lifetime
uci del dhcp.wan6
uci del network.lan.ip6assign
uci del network.wan6

uci set wireless.default_radio0.macaddr='random'
uci set wireless.default_radio1.macaddr='random'

uci commit network
uci commit wireless
uci commit


exit 0
