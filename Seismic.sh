#!/bin/bash

# 检查并安装 Rust 和 Cargo
if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null
then
    echo "Rust 和 Cargo 未安装，正在安装..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo "Rust 和 Cargo 已安装"
fi

# 检查并安装 Homebrew
if ! command -v brew &> /dev/null
then
    echo "Homebrew 未安装，正在安装..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew 已安装"
fi

# 检查并安装 jq
if ! command -v jq &> /dev/null
then
    echo "jq 未安装，正在安装..."
    if command -v brew &> /dev/null
    then
        brew install jq
    else
        echo "Homebrew 未安装，无法安装 jq"
    fi
else
    echo "jq 已安装"
fi

# 下载并执行 sfoundryup 安装脚本
echo "正在下载并执行 sfoundryup 安装脚本..."
curl -L -H "Accept: application/vnd.github.v3.raw" "https://api.github.com/repos/SeismicSystems/seismic-foundry/contents/sfoundryup/install?ref=seismic" | bash
source ~/.zshenv  # 或者 ~/.bashrc 或 ~/.zshrc

# 检查并安装 sforge
if ! command -v sforge &> /dev/null
then
    echo "sforge 未安装，正在安装..."
    cargo install sforge
else
    echo "sforge 已安装"
fi

# 检查并安装 anvil
if ! command -v anvil &> /dev/null
then
    echo "anvil 未安装，正在安装..."
    cargo install anvil
else
    echo "anvil 已安装"
fi

# 检查并安装 ssolc
if ! command -v ssolc &> /dev/null
then
    echo "ssolc 未安装，正在安装..."
    cargo install ssolc
else
    echo "ssolc 已安装"
fi

# 克隆 seismic-starter 仓库并运行 sforge 测试
echo "正在克隆 seismic-starter 仓库..."
git clone "https://git@github.com/SeismicSystems/seismic-starter.git"
cd seismic-starter/packages/contracts
sforge test -vv

echo "所有检查和安装已完成"
