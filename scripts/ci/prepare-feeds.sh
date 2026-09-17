#!/bin/sh
# Faster CI feeds: shallow clone, skip unused feeds.
set -e

sed -i 's/^src-git-full /src-git /' feeds.conf.default
sed -i '/telephony/d; /routing/d; /modemfeed/d' feeds.conf.default

git config --global core.compression 1
git config --global advice.detachedHead false
git config --global http.version HTTP/1.1

./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install luci-theme-argon luci-app-argon-config \
	luci-app-ttyd luci-app-sqm
test -e package/feeds/luci/luci-theme-argon/Makefile
