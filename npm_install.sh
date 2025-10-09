#!/bin/bash

#------------------------------------------------------------------------------
# 脚本功能：
# 1. 使用 curl 安装 nvm (Node Version Manager)
# 2. 设置清华大学镜像源来安装 Node.js v22
# 3. 切换 npm 的 registry 到清华大学镜像源
# 4. 全局安装 pnpm (增加失败重试逻辑)
# 5. 验证 pnpm 的 registry 是否已正确设置
#------------------------------------------------------------------------------

# 如果任何命令执行失败，则立即退出脚本
set -e

# --- 步骤 1: 安装 nvm ---
echo "--- 步骤 1: 正在安装 nvm (v0.40.0)... ---"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# --- 加载 nvm ---
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    echo "nvm 已成功加载到当前脚本环境。"
else
    echo "错误：无法找到 nvm.sh 脚本。请检查 nvm 是否正确安装到 $NVM_DIR。" >&2
    exit 1
fi

# --- 步骤 2: 使用清华镜像安装 Node.js v22 ---
echo ""
echo "--- 步骤 2: 正在设置 Node.js 镜像源并安装 Node.js v22... ---"
export NVM_NODEJS_ORG_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/
nvm install 22
nvm use 22
echo "Node.js v22 安装完成。当前版本："
node -v

# --- 步骤 3: 切换 npm 镜像源为清华大学镜像 ---
echo ""
echo "--- 步骤 3: 正在切换 npm 镜像源为清华大学镜像... ---"
npm config set registry https://mirrors.tuna.tsinghua.edu.cn/npm/
echo "npm 镜像源已成功切换为：$(npm config get registry)"

# --- 步骤 4: 全局安装 pnpm (带失败重试功能) ---
echo ""
echo "--- 步骤 4: 正在尝试从清华源全局安装 pnpm... ---"
if ! npm install -g pnpm; then
    echo "⚠️  清华源安装 pnpm 失败。正在尝试切换到 npm 官方源后重试..."
    npm config set registry https://registry.npmjs.org/
    npm install -g pnpm
fi
# 无论上面是否成功，最后都把源切回用户指定的清华源
echo "=> 将 npm 镜像源恢复为清华源..."
npm config set registry https://mirrors.tuna.tsinghua.edu.cn/npm/
echo "pnpm 安装完成。当前版本："
pnpm -v


# --- 步骤 5: 检查当前的 pnpm 镜像源 ---
echo ""
echo "--- 步骤 5: 正在检查当前的 pnpm 镜像源... ---"
CURRENT_PNPM_REGISTRY=$(pnpm config get registry)
echo "pnpm 当前使用的镜像源是: $CURRENT_PNPM_REGISTRY"

if [ "$CURRENT_PNPM_REGISTRY" = "https://mirrors.tuna.tsinghua.edu.cn/npm/" ]; then
    echo "✅ 验证成功：pnpm 镜像源已正确设置为清华大学镜像。"
else
    echo "⚠️ pnpm 镜像源未自动设置为清华大学镜像。您可以尝试手动设置：" >&2
    echo "   pnpm config set registry https://mirrors.tuna.tsinghua.edu.cn/npm/" >&2
fi

echo ""
echo "🎉 脚本执行完毕！"
