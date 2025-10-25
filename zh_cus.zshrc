# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Proxy management functions
export PROXY=OFF
proxy() {
    export https_proxy=http://127.0.0.1:12421 http_proxy=http://127.0.0.1:12421 all_proxy=socks5://127.0.0.1:12421
    export PROXY=ON
    echo "Proxy enabled"
}
noproxy() {
    unset https_proxy http_proxy all_proxy
    export PROXY=OFF
    echo "Proxy disabled"
}

# Python package mirrors (for Chinese regions)
export tsmirror=https://pypi.tuna.tsinghua.edu.cn/simple
export zju=https://mirrors.zju.edu.cn/pypi/web/simple
export HF_ENDPOINT=https://hf-mirror.com

# Initialize Starship prompt (if installed)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# UV shell completions (if installed)
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# UVX shell completions (if installed)
if command -v uvx &> /dev/null; then
    eval "$(uvx --generate-shell-completion zsh)"
fi

