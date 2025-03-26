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
}

# 运行主菜单
main_menu
