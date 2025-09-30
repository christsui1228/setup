#!/bin/bash

# ==============================================================================
# Script Name:   install_docker.sh
# Description:   在 Ubuntu 24.04 (Noble Numbat) 上安装最新版的 Docker CE。
#                此脚本基于 Docker 官方文档的推荐步骤。
# Author:        Gemini
# Date:          2025-09-30
# ==============================================================================

# 设置错误处理：任何命令执行失败，脚本都会立即退出
set -e

# --- 权限检查 ---
if [ "$(id -u)" -ne 0 ]; then
   echo "错误：此脚本必须以 root 权限运行。请使用 'sudo ./install_docker.sh'。" >&2
   exit 1
fi

echo "--- 开始执行 Docker 安装脚本 ---"

# --- 步骤 1: 卸载旧版本 ---
echo "--> 正在卸载任何可能存在的旧版本 Docker..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    apt-get remove -y $pkg > /dev/null 2>&1 || true
done
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras > /dev/null 2>&1 || true
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

# --- 步骤 2: 安装必要的依赖包 ---
echo "--> 正在更新软件包列表并安装依赖..."
apt-get update
apt-get install -y ca-certificates curl

# --- 步骤 3: 添加 Docker 的官方 GPG 密钥 ---
echo "--> 正在添加 Docker 官方 GPG 密钥..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# --- 步骤 4: 添加 Docker 的 APT 软件源 ---
echo "--> 正在添加 Docker 的 APT 软件源..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# --- 步骤 5: 安装最新版本的 Docker Engine ---
echo "--> 正在安装最新版本的 Docker Engine..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- 步骤 6: (可选但推荐) 配置非 root 用户权限 ---
# 检查调用脚本的用户是否存在（如果直接用 root 运行，则 Sudo user 为空）
SUDO_USER=$(logname 2>/dev/null || echo ${SUDO_USER:-$USER})

if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    echo "--> 正在将用户 '$SUDO_USER' 添加到 'docker' 组..."
    usermod -aG docker $SUDO_USER
    echo "✅ 用户 '$SUDO_USER' 已添加到 docker 组。"
    echo "   请注意：你需要注销并重新登录，此更改才能完全生效！"
else
    echo "--> 跳过添加用户到 docker 组（当前用户是 root 或未检测到 sudo 用户）。"
fi

# --- 完成 ---
echo ""
echo "✅ Docker 安装成功！"
echo "   版本信息："
docker --version
echo ""
echo "   正在运行 hello-world 容器以验证安装..."

# 使用 docker run 命令时，即使当前 shell 的组权限还未刷新，
# 以 root 身份运行也能成功，从而验证安装本身。
docker run hello-world
