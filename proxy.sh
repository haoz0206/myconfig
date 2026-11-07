# Optional HTTP/SOCKS proxy helpers. Source explicitly from local.sh.
proxy() {
    local addr="${PROXY_IP:-127.0.0.1}:${PROXY_PORT:-12421}"
    export https_proxy="http://$addr" http_proxy="http://$addr" all_proxy="socks5://$addr"
    export PROXY=ON
}
noproxy() {
    unset https_proxy http_proxy all_proxy
    export PROXY=OFF
}
