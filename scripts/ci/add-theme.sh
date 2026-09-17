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
exit 0
EOF
chmod +x files/etc/uci-defaults/30-default-theme
