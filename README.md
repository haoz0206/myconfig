# MyConfig - Environment Setup Scripts

Automated environment configuration for Bash and Zsh shells with Starship prompt and modern Python tooling.

## Features

- **Automatic shell detection** - Detects your current shell (Bash/Zsh) and configures it automatically
- **Starship prompt** - Beautiful, customizable shell prompt with One Dark Pro theme
- **UV package manager** - Optional Python package manager installation
- **Proxy management** - Easy proxy on/off functions for network settings
- **Python mirrors** - Pre-configured mirrors for Chinese regions (Tsinghua, ZJU)
- **Safe and idempotent** - Can be run multiple times without issues
- **Automatic backups** - Backs up existing configurations before modifying
- **Error handling** - Comprehensive error checking and clear status messages
- **Graceful degradation** - Shell completions only load if tools are installed

## Quick Start

```bash
git clone <your-repo-url> ~/myconfig
cd ~/myconfig
bash setup.sh
```

Follow the interactive prompts, then restart your shell or run:

```bash
source ~/.bashrc   # for Bash
# or
source ~/.zshrc    # for Zsh
```

## What Gets Configured

### Automatic Detection
The script automatically detects your current shell and offers to configure:
- **Single shell mode** (default): Configures only your detected shell
- **Both shells mode**: Configures both Bash and Zsh

### Installed Components
1. **Starship** - Modern cross-shell prompt
2. **UV** (optional) - Fast Python package manager
3. **Shell configurations** - Custom RC files with useful aliases and functions

### Custom Functions

#### Proxy Management
```bash
proxy      # Enable proxy (HTTP/HTTPS/SOCKS5 on port 12421)
noproxy    # Disable proxy
```

#### Python Mirrors
```bash
# Automatically configured environment variables:
$tsmirror    # Tsinghua mirror
$zju         # ZJU mirror
$HF_ENDPOINT # HuggingFace mirror
```

## File Structure

```
myconfig/
├── setup.sh           # Main setup script
├── zh_cus.bashrc      # Bash configuration
├── zh_cus.zshrc       # Zsh configuration
├── starship.toml      # Starship prompt config
├── custom.bashrc      # Generated Bash RC (gitignored)
├── custom.zshrc       # Generated Zsh RC (gitignored)
└── README.md          # This file
```

## Improvements in Latest Version

### Critical Fixes
- ✅ **Fixed UV_CACHE_DIR bug** - Cache directory now correctly saved
- ✅ **Automatic RC file updates** - No manual copying required
- ✅ **Idempotent execution** - Safe to run multiple times

### New Features
- ✅ **Automatic shell detection** - Detects Bash/Zsh automatically
- ✅ **Comprehensive error handling** - Clear error messages and exit codes
- ✅ **Automatic backups** - Timestamped backups of modified files
- ✅ **Prerequisites checking** - Verifies required tools are installed
- ✅ **Graceful tool loading** - Shell completions only load if tools exist
- ✅ **Color-coded output** - Clear status messages (INFO/SUCCESS/WARNING/ERROR)
- ✅ **Path validation** - Checks and creates directories as needed
- ✅ **Smart symlink handling** - Replaces existing symlinks safely

### Code Quality
- ✅ **Standardized comments** - All English, clear documentation
- ✅ **Better user feedback** - Informative messages throughout setup
- ✅ **Rollback instructions** - Clear guidance on reverting changes

## Rollback

If you need to revert changes:

```bash
# List backup files
ls -la ~/*.backup.*

# Restore from backup (example)
cp ~/.bashrc.backup.20231025_143022 ~/.bashrc
```

## Customization

### Proxy Settings
Edit the proxy URLs in `zh_cus.bashrc` or `zh_cus.zshrc`:
```bash
proxy() {
    export https_proxy=http://YOUR_PROXY_HOST:PORT
    export http_proxy=http://YOUR_PROXY_HOST:PORT
    export all_proxy=socks5://YOUR_PROXY_HOST:PORT
    export PROXY=ON
}
```

### Starship Prompt
Customize the prompt appearance by editing `starship.toml`. See [Starship documentation](https://starship.rs/config/) for details.

### UV Cache Directory
During setup, you can specify a custom cache directory for UV, or set it later:
```bash
export UV_CACHE_DIR=/path/to/cache
```

## Requirements

- Bash 4.0+ or Zsh 5.0+
- curl (for downloading installers)
- readlink (for path resolution)
- Internet connection (for initial setup)

## Troubleshooting

### Setup fails with "command not found"
Ensure curl and readlink are installed:
```bash
# Ubuntu/Debian
sudo apt install curl coreutils

# macOS (usually pre-installed)
brew install curl coreutils
```

### Starship prompt not showing
Ensure Starship is in your PATH and restart your shell:
```bash
which starship
source ~/.bashrc  # or ~/.zshrc
```

### UV completions error
This is normal if UV is not installed. The script gracefully handles missing tools.

## Contributing

Feel free to submit issues or pull requests to improve these setup scripts!

## License

MIT License - feel free to use and modify as needed.
