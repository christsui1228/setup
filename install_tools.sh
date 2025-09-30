#!/bin/bash

# ==============================================================================
# Script Name:   install_essentials.sh
# Description:   在一个基于 Debian/Ubuntu 的系统上，更新软件包列表并
#                安装一套核心开发工具。
# Author:        Your Name
# Date:          2025-09-29
# ==============================================================================

# 设置错误处理：任何命令执行失败，脚本都会立即退出
set -e

# --- 权限检查 ---
# 检查脚本是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
   echo "错误：此脚本必须以 root 权限运行。请使用 'sudo'。" >&2
   exit 1
fi

# --- 变量定义 ---
# 将需要安装的软件包列表定义为一个变量，方便未来修改
PACKAGES_TO_INSTALL="curl vim python3-venv"

# --- 脚本主体 ---
echo "--> 步骤 1/2: 正在更新软件包列表..."
apt update

echo "" # 打印一个空行，方便阅读
echo "--> 步骤 2/2: 正在安装以下软件包: ${PACKAGES_TO_INSTALL}..."
apt install -y $PACKAGES_TO_INSTALL

echo "" # 打印一个空行
echo "✅ 操作成功完成！所有软件包已安装。
