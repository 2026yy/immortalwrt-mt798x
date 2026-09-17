#!/bin/sh
# Sync SQM / eqos-mtk / turboacc-mtk with the live NX30-PRO.

sqm_if="wan"
[ -e /sys/class/net/eth1 ] && sqm_if="eth1"
[ -e /sys/class/net/wan ] && sqm_if="wan"

if uci -q get sqm >/dev/null || [ -x /etc/init.d/sqm ]; then
	uci -q delete sqm
	uci set sqm."$sqm_if"=queue
	uci set sqm."$sqm_if".enabled='0'
	uci set sqm."$sqm_if".interface="$sqm_if"
	uci set sqm."$sqm_if".download='85000'
	uci set sqm."$sqm_if".upload='10000'
	uci set sqm."$sqm_if".qdisc='cake'
	uci set sqm."$sqm_if".script='piece_of_cake.qos'
	uci set sqm."$sqm_if".qdisc_advanced='0'
	uci set sqm."$sqm_if".ingress_ecn='ECN'
	uci set sqm."$sqm_if".egress_ecn='ECN'
	uci set sqm."$sqm_if".qdisc_really_really_advanced='0'
	uci set sqm."$sqm_if".itarget='auto'
	uci set sqm."$sqm_if".etarget='auto'
	uci set sqm."$sqm_if".linklayer='none'
	uci commit sqm
fi

if uci -q get eqos.config >/dev/null || [ -x /etc/init.d/eqos ]; then
	uci set eqos.config=eqos
	uci set eqos.config.enabled='0'
	uci set eqos.config.download='100'
	uci set eqos.config.upload='20'
	uci commit eqos
fi

uci -q batch <<-EOF
	set turboacc.global=turboacc
	set turboacc.global.set='1'
	set turboacc.config=turboacc
	set turboacc.config.fastpath='mediatek_hnat'
	set turboacc.config.fastpath_mh_eth_hnat='1'
	set turboacc.config.fastpath_mh_eth_hnat_v6='1'
	set turboacc.config.fastpath_mh_eth_hnat_macvlan='0'
	set turboacc.config.fastpath_mh_eth_hnat_bind_rate='30'
	set turboacc.config.fastpath_mh_eth_hnat_ppenum='2'
	set turboacc.config.fullcone='2'
	set turboacc.config.tcpcca='cubic'
	commit turboacc
EOF

uci -q set firewall.@defaults[0].fullcone='1'
uci -q set firewall.@defaults[0].fullcone6='0'
uci -q set firewall.@defaults[0].flow_offloading='0'
uci -q set firewall.@defaults[0].flow_offloading_hw='0'
uci commit firewall

exit 0
