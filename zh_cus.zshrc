# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export PROXY=OFF
proxy() {
    export https_proxy=http://127.0.0.1:12421 http_proxy=http://127.0.0.1:12421 all_proxy=socks5://127.0.0.1:12421
    export PROXY=ON
}
noproxy() {
    unset https_proxy http_proxy all_proxy
    export PROXY=OFF
}

export tsmirror=https://pypi.tuna.tsinghua.edu.cn/simple
export zju=https://mirrors.zju.edu.cn/pypi/web/simple
export HF_ENDPOINT=https://hf-mirror.com


eval "$(starship init zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

