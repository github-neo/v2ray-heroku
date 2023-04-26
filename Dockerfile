FROM v2fly/v2fly-core:latest

RUN apk add caddy
RUN apk add gettext
RUN apk add curl
RUN apk add jq

COPY html /root/html/

COPY config.json.tp /root/
# COPY caddy.template.conf /root/
COPY Caddyfile_http /root/
COPY Caddyfile_https /root/
# COPY cert /root/cert/

ADD startup.sh /startup.sh
RUN chmod +x /startup.sh

ENTRYPOINT [ "/bin/sh" ]
CMD ["/startup.sh"]


