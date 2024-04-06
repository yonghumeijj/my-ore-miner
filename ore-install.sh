#!/bin/bash

echo "请选择操作："
echo "1) 安装 Rust 和 Cargo"
echo "2) 安装 Solana CLI 并生成密钥对"
echo "3) 安装 Ore CLI"
echo "4) 安装 nvm、Node.js 和全局安装 pm2"
echo "5) 用 pm2 运行 Ore 矿工"
echo "6) 查看奖励数量"
echo "7) 用pm2 运行 Ore 提取奖励"
echo "8) 安装systemstate包(使用9 查看CPU占用)"
echo "9) 查看15秒CPU占用"
read -p "请输入选项 [1-7]: " choice

default_rpc="https://api.mainnet-beta.solana.com"
default_threads=8

case $choice in
    1)
        echo "正在安装 Rust 和 Cargo..."
        curl https://sh.rustup.rs -sSf | sh
        source ~/.bashrc
        echo "请运行 source .bashrc"
        ;;
    2)
        echo "正在安装 Solana CLI..."
        sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"
        echo "正在生成 Solana 密钥对..."
        export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
        solana-keygen new --derivation-path m/44'/501'/0'/0' --force
        cat ~/.config/solana/id.json
        echo "请将上面的钱包信息保存..."
        ;;
    3)
        echo "正在安装 Ore CLI..."
        apt-get update
        apt-get install build-essential
        cargo install ore-cli
        ;;
    4)
        echo "正在安装 nvm、Node.js 和全局安装 pm2..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        nvm install node # 安装最新版本的 Node.js 和 npm
        npm install pm2@latest -g
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        echo "请运行 source .bashrc"

        ;;
    5)
        echo "创建 Ore 矿工运行脚本..."
        read -p "请输入 Ore RPC 地址 [直接回车则默认: ${default_rpc}]: " rpc
        rpc=${rpc:-$default_rpc}
        read -p "请输入挖矿线程数 [直接回车则默认: ${default_threads}]: " threads
        threads=${threads:-$default_threads}
        echo "#!/bin/bash" > ore_miner.sh
        echo "ore --rpc ${rpc} --keypair ~/.config/solana/id.json --priority-fee 500000 mine --threads ${threads}" >> ore_miner.sh
        chmod +x ore_miner.sh
        echo "使用 pm2 启动 Ore 矿工运行脚本..."
        pm2 start ore_miner.sh --name ore-miner
        echo "Ore 矿工运行脚本已经通过 pm2 在后台启动。"
        ;;
    6)
        ore --rpc https://api.mainnet-beta.solana.com --keypair ~/.config/solana/id.json rewards
        ;;
    7)
        echo "创建 Ore 提取运行脚本..."
        read -p "请输入 Ore RPC 地址 [默认: ${default_rpc}]: " rpc
        rpc=${rpc:-$default_rpc}
        echo "#!/bin/bash" > ore_miner.sh
        echo "ore --rpc ${rpc} --keypair ~/.config/solana/id.json --priority-fee 500000 claim" >> ore_claimer.sh
        chmod +x ore_claimer.sh
        echo "使用 pm2 启动 Ore 矿工运行脚本..."
        pm2 start ore_claimer.sh --name ore-claimer
        echo "Ore 矿工运行脚本已经通过 pm2 在后台启动。"
        ;;
    8）
        echo "安装systate查看CPU占用工具"
        sudo apt install sysstat
        ;;
    9)
        sar -u 1 15    
    *)
        echo "选择了无效的选项。退出。"
        exit 1
      ;;
esac

echo "操作完成。"
