# myconfig

适用于 Linux 和 macOS 的个人终端配置：Zsh、Gruvbox Starship 提示符、tmux 和常用命令行工具。软件统一通过 Homebrew 安装；代理和镜像不会默认启用。

## 安装

首先准备 Git、curl 和系统构建工具。Ubuntu/Debian 可以执行：

```bash
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git
```

然后克隆并运行：

```bash
git clone git@github.com:haoz0206/myconfig.git ~/myconfig
cd ~/myconfig
bash setup.sh
```

也可以使用 HTTPS 克隆：`git clone https://github.com/haoz0206/myconfig.git ~/myconfig`。安装脚本会查找 Homebrew；如果没有找到，会运行 [Homebrew 官方安装脚本](https://brew.sh/)，可能需要 sudo 和交互确认。Homebrew 安装完成后，脚本使用它安装 `zsh`、`tmux`、`starship`、`fzf`、`zoxide`、`uv`、`eza` 和 `zinit`。插件由 zinit 在首次交互式 Zsh 启动时下载，需要网络连接。

启动 `zsh` 或重新打开终端即可使用。脚本不会修改系统登录 shell；如需默认使用 Homebrew 的 Zsh，先将 `$(brew --prefix)/bin/zsh` 加入 `/etc/shells`，再运行 `chsh -s "$(brew --prefix)/bin/zsh"`，重新登录生效。

只部署配置、不安装或更新软件：

```bash
bash setup.sh --no-install
```

Starship 和部分 tmux 符号需要终端使用 [Nerd Font](https://www.nerdfonts.com/)；终端还应支持真彩色。

## 部署与更新

脚本将 `zshrc`、`shell_common.sh`、`proxy.sh`、`starship.toml` 和 `tmux.conf` 复制到 `~/.myconfig/`，并创建：

- `~/.config/starship.toml` → `~/.myconfig/starship.toml`
- `~/.tmux.conf` → `~/.myconfig/tmux.conf`
- `~/.zshrc` 中的一行 source，保留原有内容。

重复运行会更新部署文件。被替换的文件和有冲突的链接会先改名为带 `.myconfig-backup-时间戳` 后缀的备份；内容不变时不会重复备份。`~/.myconfig/local.sh` 首次运行时从模板创建，之后始终保留。修改仓库文件后再次运行脚本以部署；`--no-install` 适合只更新配置。

## 终端功能

- Starship 使用 Gruvbox 深色主题，显示用户、目录、Git 状态、语言环境和时间。Node.js 模块按当前主题设置禁用。
- Zsh 使用 zinit 加载 `zsh-autosuggestions`、`zsh-completions`、`fzf-tab` 和 `fast-syntax-highlighting`；集成 fzf、zoxide、uv 和 eza。
- tmux 前缀为 `Ctrl+s`；`|` 和 `-` 分屏，`h/j/k/l` 切换面板，`H/J/K/L` 调整大小，`v` 进入复制模式，`g` 同步面板，`z` 缩放面板。复制使用 OSC 52，需要本地终端支持。
- SSH 会话在适用的终端类型下启用真彩色；`~/.local/bin` 会加入 PATH。

## 机器专属设置与代理

编辑 `~/.myconfig/local.sh` 放置本机变量；不要把凭据提交到仓库。默认不设置代理或镜像。需要 HTTP/SOCKS 代理助手时，可以在该文件中配置：

```bash
PROXY_IP=127.0.0.1
PROXY_PORT=12421
source "$MYCONFIG_DIR/proxy.sh"
# proxy   # 如需每次启动时启用，取消注释
```

之后可使用 `proxy` 和 `noproxy` 切换。Starship 仅在 `PROXY=ON` 时显示 `PROXY.ON`；该提示本身不会配置代理。原有 `local.sh` 如果直接调用 `proxy`，升级后需在调用前加入上述 `source` 行。

仓库中的 `tun/` 是独立的 Linux 代理实验脚本，默认安装过程不部署或运行它。脚本会修改默认路由，恢复流程不能覆盖所有网络配置；请先阅读 `tun/README.md`，不要在依赖远程连接的机器上直接运行。

## 文件

| 文件 | 用途 |
| --- | --- |
| `setup.sh` | 安装 Homebrew 工具并部署配置 |
| `zshrc`、`shell_common.sh` | Zsh、插件和 shell 初始化 |
| `starship.toml` | Gruvbox 提示符主题 |
| `tmux.conf` | tmux 快捷键、外观和终端设置 |
| `local.sh.example`、`proxy.sh` | 本机覆盖与可选代理助手 |
| `tun/` | 实验性代理脚本，默认不运行 |

## 检查

在仓库目录运行 `bash tests/setup.sh`，可以在临时主目录中检查部署、备份和重复运行；该测试不会修改系统网络或安装软件。
