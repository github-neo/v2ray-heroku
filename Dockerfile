FROM teddysun/xray:latest

RUN apk add caddy
RUN apk add gettext
RUN apk add curl
RUN apk add jq

COPY html /root/html/

COPY v2ray_config_http.json /root/
COPY v2ray_config_https.json /root/
COPY Caddyfile_http /root/
COPY Caddyfile_https /root/

ADD startup.sh /startup.sh
RUN chmod +x /startup.sh

ENTRYPOINT [ "/bin/sh" ]
CMD ["/startup.sh"]


