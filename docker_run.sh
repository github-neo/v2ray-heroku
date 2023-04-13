UUID=$1
echo docker run --restart=always -p 80:80 -p 443:443 -e UUID=$UUID -d --name v2ray v2ray
docker run --restart=always -p 80:80 -p 443:443 -e UUID=$UUID -d --name v2ray v2ray