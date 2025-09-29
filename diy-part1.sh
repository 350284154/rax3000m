#!/bin/bash
# https://github.com/P3TERX/Actions-OpenWrt
# File: diy-part1.sh
# Description: Run before/with "scripts/feeds update -a"
# NOTE: 本脚本按你的需求：只插入 small 源；清理指定包；用 kenzok8/golang 替换 golang；
#       然后更新/安装 feeds 并执行 make menuconfig。可多次执行（幂等）。

set -euo pipefail

FEEDS_FILE="feeds.conf.default"

echo "[diy-part1] >>> Start"

# 0) 确保 feeds.conf.default 存在
if [[ ! -f "$FEEDS_FILE" ]]; then
  echo "[diy-part1] $FEEDS_FILE 不存在，创建一个空文件"
  touch "$FEEDS_FILE"
fi

# 1) 在第 2 行插入 small 源（若已存在则跳过）
if grep -qE "^[[:space:]]*src-git[[:space:]]+small[[:space:]]+https://github.com/kenzok8/small\b" "$FEEDS_FILE"; then
  echo "[diy-part1] 已存在 small 源，跳过插入"
else
  # 插入到第 2 行；如果文件不足 2 行，sed 会在末尾追加
  sed -i '2i src-git small https://github.com/kenzok8/small' "$FEEDS_FILE"
  echo "[diy-part1] 已在第 2 行插入 small 源"
fi

echo "[diy-part1] >>> 更新 feeds"
./scripts/feeds update -a

# 2) 移除指定包（存在则删，不存在忽略）
echo "[diy-part1] >>> 清理指定包"
rm -rf feeds/luci/applications/luci-app-mosdns || true
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns} || true
rm -rf feeds/packages/utils/v2dat || true

# 3) 替换 golang 为 kenzok8/golang（无分支，取默认）
echo "[diy-part1] >>> 替换 golang 为 kenzok8/golang"
rm -rf feeds/packages/lang/golang || true
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang

# 4) 安装所有 feeds
echo "[diy-part1] >>> 安装所有 feeds"
./scripts/feeds install -a

# 5) 进入配置界面（如在 CI 无交互环境，可改为 make defconfig）
echo "[diy-part1] >>> 运行 make menuconfig（本地交互使用；CI 无交互时可改为 make defconfig）"
make menuconfig || true

echo "[diy-part1] >>> Done"
