#!/bin/sh
# Re-select extra packages after defconfig. Feed packages (Argon/ttyd/SQM)
# are otherwise dropped silently and the image still builds.
set -e

ROOT="${1:-.}"
cd "$ROOT"

PKGS="
luci-theme-argon
luci-app-argon-config
luci-app-ttyd
ttyd
luci-i18n-ttyd-zh-cn
luci-app-sqm
sqm-scripts
luci-i18n-sqm-zh-cn
wget-ssl
jsonfilter
libwebsockets-full
libuv
libcap
"

reselect() {
	sed -i "/^CONFIG_PACKAGE_${1}=/d; /^# CONFIG_PACKAGE_${1} is not set/d" .config
	echo "CONFIG_PACKAGE_${1}=y" >> .config
}

for p in $PKGS; do
	reselect "$p"
done
sed -i '/^CONFIG_PACKAGE_libwebsockets-openssl=/d; /^# CONFIG_PACKAGE_libwebsockets-openssl is not set/d' .config
echo '# CONFIG_PACKAGE_libwebsockets-openssl is not set' >> .config

make defconfig

missing=
for p in luci-theme-argon luci-app-ttyd luci-app-sqm ttyd sqm-scripts; do
	if ! grep -q "^CONFIG_PACKAGE_${p}=y" .config; then
		echo "ERROR: CONFIG_PACKAGE_${p} was not selected after defconfig"
		grep -E "$p" .config || true
		missing=1
	fi
done

if [ -n "$missing" ]; then
	echo "Required LuCI extra packages were dropped; refusing to build a broken image."
	exit 1
fi

device="${DEVICE:-}"
if [ -n "$device" ] && [ "$device" != "all-mt7981-devices" ]; then
	if ! grep -q "^CONFIG_TARGET_mediatek_mt7981_DEVICE_${device}=y" .config; then
		echo "ERROR: profile ${device} was not selected after defconfig"
		grep -E 'CONFIG_TARGET_.*DEVICE_|CONFIG_TARGET_MULTI_PROFILE|CONFIG_TARGET_PROFILE' .config || true
		exit 1
	fi
	if grep -q '^CONFIG_TARGET_mediatek_mt7981_DEVICE_mt7981-spim-nor-rfb=y' .config; then
		echo "ERROR: defconfig fell back to mt7981-spim-nor-rfb"
		exit 1
	fi
	echo "Target profile:"
	grep -E '^CONFIG_TARGET_(MULTI_PROFILE|PER_DEVICE_ROOTFS|PROFILE|mediatek_mt7981_DEVICE_)' .config || true
fi

echo "Required extra packages are selected:"
grep -E '^CONFIG_PACKAGE_(luci-theme-argon|luci-app-argon-config|luci-app-ttyd|ttyd|luci-app-sqm|sqm-scripts)=' .config
