#!/usr/bin/env bash

set -euo pipefail

readonly password_file="${BLESK_LND_HOME}/.lnd/password.txt"
if [[ ! -f "$password_file" ]]; then
  echo "${BLESK_LND_PASSWORD}" > "$password_file"
fi

export password_file
envsubst < "${BLESK_LND_HOME}/lnd.conf.template" > "${BLESK_LND_HOME}/.lnd/lnd.conf"
chmod 0640 "${BLESK_LND_HOME}/.lnd/lnd.conf"
export -n password_file

exec lnd
