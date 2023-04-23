UUID=$1
if [[ ! -n "$UUID" ]]; then
    UUID=$(uuidgen)
fi
echo UUID: $UUID
echo docker run --restart=always -v "$HOME/cert":/root/cert -p 80:80 -p 443:443 -e UUID=$UUID -d --name caddy_v2ray caddy_v2ray
docker run --restart=always -v "$HOME/cert":/root/cert -p 80:80 -p 443:443 -e UUID=$UUID -d --name caddy_v2ray caddy_v2ray