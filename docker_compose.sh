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
_log UUID=$UUID
_log CF_Token=$CF_Token
_log CF_Account_ID=$CF_Account_ID

if [[ ! -n "$UUID" ]]; then
    _log "UUID is missed, generating a new UUID ..."
    UUID=$(uuidgen)
fi
export UUID
_log UUID: $UUID

_log docker compose config
docker compose config

_log "docker compose up -d"
docker compose up -d

# Options for debugging acme.sh:  --debug 3 --log-level 2 --syslog 7 --log
_log "docker exec acme.sh --register-account -m $EMAIL"
docker exec acme.sh --register-account -m $EMAIL

_log "docker exec --env-file $ENV_FILE acme.sh --issue --dns dns_cf -d $DOMAIN"
docker exec --env-file $ENV_FILE acme.sh --issue --dns dns_cf -d $DOMAIN

_log docker exec acme.sh --deploy --deploy-hook docker -d $DOMAIN
docker exec acme.sh --deploy --deploy-hook docker -d $DOMAIN