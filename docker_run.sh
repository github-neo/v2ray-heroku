UUID=$1
if [[ ! -n "$UUID" ]]; then
    UUID=$(uuidgen)
fi
echo UUID: $UUID
echo docker run --restart=always -p 80:80 -p 443:443 -e UUID=$UUID -d --name v2ray v2ray
docker run --restart=always -p 80:80 -p 443:443 -e UUID=$UUID -d --name v2ray v2ray