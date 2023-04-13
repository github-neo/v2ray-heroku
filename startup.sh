#!/bin/sh

echo "start to run startup ..."

envsubst < /root/config.json.tp > /root/config.json
# envsubst '\$PORT' < /root/nginx.template.conf > /root/nginx.conf

# get random page from wikipedia
if [[ -e "/root/html/index.html" ]]; then
    echo "index.html exsit, skip genreate index page"
else
    randomurl=$(curl -L 'https://en.wikipedia.org/api/rest_v1/page/random/summary' | jq -r '.content_urls.desktop.page')
    echo $randomurl
    curl "$randomurl" -o /root/html/index.html
fi

if [[ -e "/root/cert/fullchain.pem" ]] && [[ -e "/root/cert/privkey.pem" ]]; then
    cp -f /root/Caddyfile_https /root/Caddyfile
else
    cp -f /root/Caddyfile_http /root/Caddyfile
fi

# Run V2Ray
echo "Start V2Ray ..."
if [[ $TUNNEL_TOKEN ]]; then
echo 'has tunnel token, run cloudflared tunnel'
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /root/cloudflared
chmod +x /root/cloudflared
# /usr/bin/v2ray -config /root/config.json & /root/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN & nginx -c /root/nginx.conf -g 'daemon off;'
echo "Start V2Ray and cloudflared tunnel"
v2ray run -c /root/config.json & caddy run --config /root/Caddyfile & /root/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN --protocol http2
else
echo "Start V2Ray without cloudflared"
v2ray run -c /root/config.json & caddy run --config /root/Caddyfile
fi

