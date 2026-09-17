#!/bin/sh
# Replace stock Argon with jerrykuku Argon (LuCI 21.02 / lua).
set -e

ROOT="${1:-.}"
cd "$ROOT"

rm -rf feeds/luci/themes/luci-theme-argon \
	package/luci-theme-argon \
	package/luci-app-argon-config

git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

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
