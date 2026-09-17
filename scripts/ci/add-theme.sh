#!/bin/sh
# Use ImmortalWrt 21.02 feed Argon as the default LuCI theme.
# Patch virtual wget/curl deps so make defconfig does not drop the package.
set -e

ROOT="${1:-.}"
cd "$ROOT"

# package/feeds/... is a symlink into feeds/...; patch the real file once.
# A second pass would turn +wget-ssl into the nonexistent +wget-ssl-ssl.
patched=
for mk in \
	feeds/luci/themes/luci-theme-argon/Makefile \
	package/feeds/luci/luci-theme-argon/Makefile
do
	[ -f "$mk" ] || continue
	real=$(readlink -f "$mk" 2>/dev/null || realpath "$mk" 2>/dev/null || echo "$mk")
	case " $patched " in
		*" $real "*) continue ;;
	esac
	sed -i -E 's/\+wget(-ssl)?/+wget-ssl/g; s/\+curl/+wget-ssl/g' "$real"
	if grep -q 'wget-ssl-ssl' "$real"; then
		echo "ERROR: $real still has wget-ssl-ssl after patching"
		exit 1
	fi
	patched="$patched $real"
done

if [ ! -e package/feeds/luci/luci-theme-argon/Makefile ] && [ ! -e feeds/luci/themes/luci-theme-argon/Makefile ]; then
	echo "ERROR: luci-theme-argon was not installed from the luci feed"
	exit 1
fi

mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/30-default-theme <<'EOF'
#!/bin/sh
uci -q batch <<-EOT
	set luci.themes.Argon='/luci-static/argon'
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
