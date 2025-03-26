# 部署合约的函数
deploy_contract() {
    # 检查是否安装 Rust
    if command -v rustc &> /dev/null
    then
        echo "Rust 已安装，当前版本：$(rustc --version)"
    else
        echo "Rust 未安装，正在安装..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
        echo "Rust 安装完成，当前版本：$(rustc --version)"
    fi

    # 检查是否安装 jq
    if command -v jq &> /dev/null
    then
        echo "jq 已安装，当前版本：$(jq --version)"
    else
        echo "jq 未安装，正在安装..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        else
            echo "不支持的系统，请手动安装 jq"
            exit 1
        fi
        echo "jq 安装完成，当前版本：$(jq --version)"
    fi

    # 检查是否安装 unzip
    if command -v unzip &> /dev/null
    then
        echo "unzip 已安装"
    else
        echo "unzip 未安装，正在安装..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y unzip
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install unzip
        else
            echo "不支持的系统，请手动安装 unzip"
            exit 1
        fi
        echo "unzip 安装完成"
    fi

    # 下载并执行 Seismic Foundry 安装脚本
    curl -L -H "Accept: application/vnd.github.v3.raw" "https://api.github.com/repos/SeismicSystems/seismic-foundry/contents/sfoundryup/install?ref=seismic" | bash

    # 重新加载 shell 配置
    source ~/.bashrc

    # 运行 sfoundryup
    sfoundryup

    # 克隆 SeismicSystems/try-devnet 仓库并进入目录
    git clone --recurse-submodules https://github.com/SeismicSystems/try-devnet.git
    cd try-devnet/packages/contract/

    # 执行部署脚本
    bash script/deploy.sh

    # 提示用户按任意键返回主菜单
    echo "合约部署完成，按任意键返回主菜单..."
    read -n 1 -s
}

# 合约交互的函数
interact_contract() {
    cd try-devnet/packages/cli/
    
    # 安装 Bun
    curl -fsSL https://bun.sh/install | bash
    source ~/.bashrc  # 确保 Bun 命令可用

    # 安装依赖
    bun install
    
    # 运行交易脚本
    bash script/transact.sh

    # 提示用户按任意键返回主菜单
    echo "合约交互完成，按任意键返回主菜单..."
    read -n 1 -s
}
