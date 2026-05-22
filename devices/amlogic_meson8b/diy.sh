#!/bin/bash

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

#bash $SHELL_FOLDER/../common/kernel_6.1.sh

#rm -rf package/kernel/mac80211

#git_clone_path c640f7b93736621b4d56627e4f6ab824093f9c3d https://github.com/openwrt/openwrt package/kernel/mac80211

sed -i 's/Os/O2/g' include/target.mk

git_clone_path main https://github.com/lxiaya/openwrt-onecloud target/linux/amlogic

mv -f target/linux/amlogic/patches-6.6 target/linux/amlogic/patches-6.12
mv -f target/linux/amlogic/meson8b/config-6.6 target/linux/amlogic/meson8b/config-6.12

sed -i "s/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/" target/linux/amlogic/Makefile

sed -i "s/wpad-openssl/wpad-basic-mbedtls/" target/linux/amlogic/image/Makefile

sed -i "s/neon-vfpv4/vfpv4/" target/linux/amlogic/meson8b/target.mk
# 强制替换 SoftEther VPN 源码为 Debian 归档的 5.01.9674 版本
echo "正在将 SoftEther VPN 锁定为 Debian 归档的 5.01.9674 版本..."
sleep 2

# 查找 softethervpn5 软件包的 Makefile 路径
SE_MAKEFILE=$(find ./feeds -name "Makefile" -path "*/softethervpn5/*" 2>/dev/null | head -1)
if [ -z "$SE_MAKEFILE" ]; then
    SE_MAKEFILE=$(find ./package -name "Makefile" -path "*/softethervpn5/*" 2>/dev/null | head -1)
fi

if [ -n "$SE_MAKEFILE" ]; then
    echo "找到 Makefile: $SE_MAKEFILE"
    # 修改 PKG_VERSION 为 5.01.9674（忽略 Debian 后缀）
    sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=5.01.9674/' "$SE_MAKEFILE"
    # 修改源码下载 URL 为 Debian 官方池地址
    sed -i 's|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=http://deb.debian.org/debian/pool/main/s/softether-vpn/|' "$SE_MAKEFILE"
    # 修改源码文件名
    sed -i 's/PKG_SOURCE:=.*/PKG_SOURCE:=softether-vpn_5.01.9674+git20200806+8181039+dfsg2.orig.tar.xz/' "$SE_MAKEFILE"
    # 跳过哈希检查（因为原 Makefile 中的哈希不匹配新源码）
    sed -i 's/PKG_HASH:=.*/PKG_HASH:=skip/' "$SE_MAKEFILE"
    echo "SoftEther VPN 源码已切换到 Debian 5.01.9674 归档版本"
else
    echo "警告: 未找到 softethervpn5 的 Makefile，版本锁定失败"
fi

