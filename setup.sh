echo "Setting up environment..."

# starship
curl -sS https://starship.rs/install.sh | sh
echo "eval '$(starship init zsh)'" >> ~/.zshrc
mkdir ~/.config
cp starship.toml ~/.config/starship.toml