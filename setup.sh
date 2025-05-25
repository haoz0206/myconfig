#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ZSH_CUSTOM_FILE="$SCRIPT_DIR/zh_cus.zshrc"
BASH_CUSTOM_FILE="$SCRIPT_DIR/zh_cus.bashrc"

echo "Setting up environment..."

# starship
curl -sS https://starship.rs/install.sh | sh
mkdir ~/.config
ln -s "$SCRIPT_DIR/starship.toml" ~/.config/starship.toml

# 获取当前脚本目录路径

read -p "Do you want to install UV? (y/n) " -n 1 -r
echo    # 移动到新行
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "UV installation complete!"
else
    echo "Skipping UV installation."
fi

# 添加source命令到 ~/.zshrc
read -p "Do you want to set up UV cache directory? (y/n) " -n 1 -r
echo    # 移动到新行
if [[ $REPLY =~ ^[Yy]$ ]]
then
    read -p "Enter the path for UV cache directory: " uv_cache_dir
    echo "export UV_CACHE_DIR=$uv_cache_dir" >> custom.zshrc
    echo "export UV_CACHE_DIR=$uv_cache_dir" >> custom.bashrc
    echo "UV cache directory set to $uv_cache_dir"
else
    echo "Skipping UV cache directory setup."
fi


echo "# Custom zsh configurations" > custom.zshrc
echo "source $ZSH_CUSTOM_FILE" >> custom.zshrc
echo "Added source command 'echo \"source $SCRIPT_DIR/custom.zshrc\" >> ~/.zshrc' to ~/.zshrc for custom configurations"


echo "# Custom bash configurations" > custom.bashrc
echo "source $BASH_CUSTOM_FILE" >> custom.bashrc
echo "Added source command 'echo \"source $SCRIPT_DIR/custom.bashrc\" >> ~/.bashrc' to ~/.bashrc for custom configurations"
