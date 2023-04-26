_log() {
    printf "[$(date)] $* \n"
}

export HOME_PATH=~/acme
_log HOME_PATH=$HOME_PATH

UUID=$1
_log UUID=$UUID
if [[ ! -n "$UUID" ]]; then
    UUID=$(uuidgen)
fi
echo UUID: $UUID

echo docker run --restart=always -v "${HOME_PATH}/caddy_v2ray-cert":/root/cert -p 80:80 -p 443:443 -e UUID=$UUID -d --name caddy_v2ray caddy_v2ray
docker run --restart=always -v "${HOME_PATH}/caddy_v2ray-cert":/root/cert -p 80:80 -p 443:443 -e UUID=$UUID -d --name caddy_v2ray caddy_v2ray