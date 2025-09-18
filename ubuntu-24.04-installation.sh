#!/usr/bin/env bash
# Ubuntu 24.04 国内镜像源一键替换脚本
# 请以 root 用户运行（不需要 sudo）

set -e

# 1. 备份原始源文件
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 2. 更新索引并安装 CA 证书（确保 HTTPS 源可用）
apt update
apt install -y ca-certificates

# 3. 批量替换所有官方 Ubuntu 源地址为阿里云镜像
find /etc/apt/ -type f -name "*.list*" -exec sed -i \
  "s|http://.*ubuntu\\.com/ubuntu/|https://mirrors.aliyun.com/ubuntu/|g" {} +

# 4. 再次更新软件包索引
apt update

# 5. 显示当前镜像源配置
echo -e "\n当前有效的镜像源："
grep -hE '^deb ' /etc/apt/sources.list /etc/apt/sources.list.d/*.list

echo -e "\n镜像源已切换至阿里云，更新完成。"
