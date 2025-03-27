#!/bin/bash

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 部署合约"
        echo "2) 合约交互"
        echo "3) 退出"
        read -p "请输入选项: " choice

        case $choice in
            1)
                deploy_contract
                ;;
            2)
                interact_contract
                ;;
            3)
                exit 0
                ;;
            *)
                echo "无效选项，请重新输入"
                sleep 2
                ;;
        esac
    done
}

# 部署合约的函数
deploy_contract() {
    echo "开始部署合约..."

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
    echo "正在安装 Seismic Foundry..."
    curl -L \
     -H "Accept: application/vnd.github.v3.raw" \
     "https://api.github.com/repos/SeismicSystems/seismic-foundry/contents/sfoundryup/install?ref=seismic" | bash

    # 获取安装后新添加的路径
    NEW_PATH=$(bash -c 'source /root/.bashrc && echo $PATH')

    # 更新当前shell的PATH
    export PATH="$NEW_PATH"

    # 确保 ~/.seismic/bin 在 PATH 中
    if [[ ":$PATH:" != *":/root/.seismic/bin:"* ]]; then
    export PATH="/root/.seismic/bin:$PATH"
    fi

    # 打印当前 PATH，确保 sfoundryup 在其中
    echo "当前 PATH: $PATH"

    # 检查 sfoundryup 是否可用
    if command -v sfoundryup &> /dev/null
    then
        echo "sfoundryup 安装成功！"
    else
        echo "sfoundryup 未安装成功，请检查安装步骤。"
        exit 1
    fi

    # 运行 sfoundryup
    echo "正在运行 sfoundryup..."
    sfoundryup

    # 克隆 SeismicSystems/try-devnet 仓库并进入目录
    if [ ! -d "try-devnet" ]; then
        echo "克隆 SeismicSystems/try-devnet 仓库..."
        git clone --recurse-submodules https://github.com/SeismicSystems/try-devnet.git
    else
        echo "try-devnet 仓库已存在，跳过克隆步骤。"
    fi
    cd try-devnet/packages/contract/

    # 执行部署脚本
    echo "正在执行合约部署..."
    bash script/deploy.sh

    # 提示用户按任意键返回主菜单
    echo "合约部署完成，按任意键返回主菜单..."
    read -n 1 -s
}

# 合约交互的函数
interact_contract() {
    echo "开始合约交互..."
    cd /root/try-devnet/packages/cli/
    
    # 安装 Bun
    echo "正在安装 Bun..."
    curl -fsSL https://bun.sh/install | bash
    
    # 确保 Bun 命令可用
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    # 安装依赖
    echo "安装 Bun 依赖..."
    bun install
    
    # 运行交易脚本
    echo "正在运行合约交互脚本..."
    bash script/transact.sh

    # 提示用户按任意键返回主菜单
    echo "合约交互完成，按任意键返回主菜单..."
    read -n 1 -s
}

# 运行主菜单
main_menu

