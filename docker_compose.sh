#!/bin/bash

_log() {
    printf "[$(date)] $* \n"
}

export HOME_PATH=~/acme
_log HOME_PATH=$HOME_PATH

ENV_FILE="$HOME_PATH/acme_env.sh"

_log Read environment variables from $ENV_FILE:
. $ENV_FILE

_log EMAIL=$EMAIL
_log DOMAIN=$DOMAIN
_log CF_Token=$CF_Token
_log CF_Account_ID=$CF_Account_ID
_log UUID=$UUID
_log TCP_PORT=$TCP_PORT

if [[ ! -n "$UUID" ]]; then
    _log "UUID is missed, generating a new UUID ..."
    UUID=$(uuidgen)
fi
export UUID
_log UUID: $UUID

if [[ ! -n "$TCP_PORT" ]]; then
    _log "TCP_PORT is missed, use default port ..."
    TCP_PORT=8443
fi
export TCP_PORT
_log TCP_PORT: $TCP_PORT

_log docker compose config
docker compose config

_log "docker compose down --remove-orphans"
docker compose down --remove-orphans

_log "docker compose pull"
docker compose pull

_log "docker compose up -d"
docker compose up -d

if [[ $DOMAIN ]]; then
    _log "DOMAIN is $DOMAIN, try to get cert ..."

    DOMAIN_ARGS=""
    domain_arr=(${DOMAIN//,/ }) 
    for elm in ${domain_arr[@]}
    do
        DOMAIN_ARGS="${DOMAIN_ARGS} -d ${elm}"
    done

    # Options for debugging acme.sh:  --debug 3 --log-level 2 --syslog 7 --log
    _log "docker exec acme.sh --register-account -m $EMAIL"
    docker exec acme.sh --register-account -m $EMAIL

    _log "docker exec --env-file $ENV_FILE acme.sh --issue --dns dns_cf${DOMAIN_ARGS}"
    docker exec --env-file $ENV_FILE acme.sh --issue --dns dns_cf${DOMAIN_ARGS}

    _log "docker exec acme.sh --deploy --deploy-hook docker${DOMAIN_ARGS}"
    docker exec acme.sh --deploy --deploy-hook docker${DOMAIN_ARGS}
else
    _log "DOMAIN is missed, skip getting cert ..."
fi