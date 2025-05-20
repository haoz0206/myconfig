echo "Setting up environment..."

# starship
curl -sS https://starship.rs/install.sh | sh
mkdir ~/.config
cp starship.toml ~/.config/starship.toml

# 获取当前脚本目录路径
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ZSH_CUSTOM_FILE="$SCRIPT_DIR/zh_cus.zshrc"

read -p "Do you want to install UV? (y/n) " -n 1 -r
echo    # 移动到新行
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "UV installation complete!"
    read -p "Do you want to set up UV cache directory? (y/n) " -n 1 -r
    echo    # 移动到新行
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        read -p "Enter the path for UV cache directory: " uv_cache_dir
        echo "export UV_CACHE_DIR=$uv_cache_dir" >> zh_cus.zshrc
        echo "UV cache directory set to $uv_cache_dir"
    else
        echo "Skipping UV cache directory setup."
    fi
else
    echo "Skipping UV installation."
fi

# 添加source命令到~/.zshrc
if [ -f "$ZSH_CUSTOM_FILE" ]; then
    echo "" >> ~/.zshrc
    echo "# Custom zsh configurations" >> ~/.zshrc
    echo "source $ZSH_CUSTOM_FILE" >> ~/.zshrc
    echo "Added source command to ~/.zshrc for custom configurations"
fi