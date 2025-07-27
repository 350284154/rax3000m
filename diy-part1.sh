#!/bin/bash

# 清理旧目录
rm -rf package/luci-app-ssr-plus package/openwrt-passwall package/luci-app-passwall package/luci-app-passwall2 package/luci-app-openclash

# 加 SSR Plus feed
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default

# Passwall、Passwall2、依赖、OpenClash 用 git clone
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git clone --depth=1 --filter=blob:none --sparse https://github.com/vernesong/OpenClash package/luci-app-openclash
cd package/luci-app-openclash && git sparse-checkout set luci-app-openclash && cd -
