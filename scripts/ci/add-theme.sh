#!/bin/sh
# Use ImmortalWrt 21.02 feed Argon. Only set it as the default LuCI theme.
set -e

ROOT="${1:-.}"
cd "$ROOT"

mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/30-default-theme <<'EOF'
#!/bin/sh
uci -q batch <<-EOT
	set luci.main.mediaurlbase='/luci-static/argon'
	commit luci
EOT
if uci -q get argon.@global[0] >/dev/null; then
	uci -q set argon.@global[0].mode='normal'
	uci -q set argon.@global[0].online_wallpaper='bing'
	uci commit argon
fi
exit 0
EOF
chmod +x files/etc/uci-defaults/30-default-theme
