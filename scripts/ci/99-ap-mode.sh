#!/bin/sh
# AP mode: static LAN, disable DHCP, bridge WAN into LAN.
# Values below are filled by GitHub Actions.

LAN_IP='@LAN_IP@'
LAN_GW='@LAN_GW@'

wan_dev="$(uci -q get network.wan.device)"
[ -z "$wan_dev" ] && wan_dev="$(uci -q get network.wan.ifname)"
[ -z "$wan_dev" ] && [ -e /sys/class/net/wan ] && wan_dev="wan"
[ -z "$wan_dev" ] && [ -e /sys/class/net/eth1 ] && wan_dev="eth1"

add_port_to_brlan() {
	wanif="$1"
	[ -n "$wanif" ] || return 0
	idx=0
	while uci -q get network.@device[$idx] >/dev/null; do
		name="$(uci -q get network.@device[$idx].name)"
		if [ "$name" = "br-lan" ]; then
			ports="$(uci -q get network.@device[$idx].ports)"
			echo " $ports " | grep -q " $wanif " || uci add_list network.@device[$idx].ports="$wanif"
			return 0
		fi
		idx=$((idx + 1))
	done
	ifname="$(uci -q get network.lan.ifname)"
	if [ -n "$ifname" ]; then
		echo " $ifname " | grep -q " $wanif " || uci set network.lan.ifname="$ifname $wanif"
	fi
}

add_port_to_brlan "$wan_dev"

uci -q delete network.wan
uci -q delete network.wan6

uci set network.lan.proto='static'
uci set network.lan.ipaddr="$LAN_IP"
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway="$LAN_GW"
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='114.114.114.114'
uci add_list network.lan.dns='8.8.8.8'

uci set dhcp.lan.ignore='1'
uci -q delete dhcp.lan.dhcpv4
uci -q set dhcp.lan.ra='disabled'
uci -q set dhcp.lan.dhcpv6='disabled'

uci -q set firewall.@zone[1].masq='0'
uci -q delete firewall.@forwarding[0]

uci commit network
uci commit dhcp
uci commit firewall
exit 0
