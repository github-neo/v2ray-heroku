#!/bin/sh

_log() {
    printf "[$(date)] $* \n"
}

_log "start to run startup ..."

# envsubst '\$PORT' < /root/nginx.template.conf > /root/nginx.conf

# get random page from wikipedia
if [[ -e "/root/html/index.html" ]]; then
    _log "index.html exsit, skip genreate index page"
else
    randomurl=$(curl -L 'https://en.wikipedia.org/api/rest_v1/page/random/summary' | jq -r '.content_urls.desktop.page')
    _log $randomurl
    curl "$randomurl" -o /root/html/index.html
fi

_log use Caddyfile_http
cp -f /root/Caddyfile_http /root/Caddyfile

if [[ -e "/root/cert/fullchain.pem" ]] && [[ -e "/root/cert/privkey.pem" ]]; then
    _log use v2ray_config_https.json
    cp -f /root/v2ray_config_https.json /root/v2ray_config.json
    _log use Caddyfile_https
    cp -f /root/Caddyfile_https /root/Caddyfile
else
    _log use v2ray_config_http.json
    cp -f /root/v2ray_config_http.json /root/v2ray_config.json
    _log use Caddyfile_http
    cp -f /root/Caddyfile_http /root/Caddyfile
fi

_log populate /root/config.json
envsubst < /root/v2ray_config.json > /root/config.json

_log update geoip.dat ...
curl -Lo /usr/share/xray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
_log update geosite.dat ...
curl -Lo /usr/share/xray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

# Run V2Ray
_log "Start V2Ray ..."
if [[ $TUNNEL_TOKEN ]]; then
_log 'has tunnel token, run cloudflared tunnel'
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /root/cloudflared
chmod +x /root/cloudflared
# /usr/bin/v2ray -config /root/config.json & /root/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN & nginx -c /root/nginx.conf -g 'daemon off;'
_log "Start V2Ray and cloudflared tunnel"
# v2ray run -c /root/config.json & caddy run --watch --config /root/Caddyfile & /root/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN --protocol http2
/usr/bin/xray -config /root/config.json & caddy run --watch --config /root/Caddyfile & /root/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN --protocol http2
else
_log "Start V2Ray without cloudflared"
# v2ray run -c /root/config.json & caddy run --watch --config /root/Caddyfile
/usr/bin/xray -config /root/config.json & caddy run --watch --config /root/Caddyfile
fi