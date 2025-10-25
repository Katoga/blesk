#!/usr/bin/env bash

set -euo pipefail

# Prevent excessive memory usage
export MALLOC_ARENA_MAX=1

envsubst < "${BLESK_BITCOINCORE_HOME}/bitcoin.conf.template" > "${BLESK_BITCOINCORE_HOME}/.bitcoin/bitcoin.conf"
chmod 0600 "${BLESK_BITCOINCORE_HOME}/.bitcoin/bitcoin.conf"

bitcoind_options=(
  -externalip="$(cat "${BLESK_TOR_ONIONS}/${BLESK_BITCOINCORE_USERNAME}/hostname")"
)
if [[ "${BLESK_BITCOINCORE_INITIAL_RUN:-0}" -eq 1 ]]; then
  # Initial block download optimizations
  bitcoind_options+=(
    -dbcache="$BLESK_BITCOINCORE_DB_CACHE"
    -blocksonly=1
  )
fi

# Mimic Bitcoincore log message
log_with_date() {
  local -r msg="$1"

  echo "$(date --utc +%FT%TZ) ${msg}"
}

# Taken from Samourai Dojo (GNU AGPL v3)
# de-echo-ed for Blesk by Katoga
ban_knots() {
  log_with_date "Running ban script"

  local addr base_addr id

  # Get all Knots nodes
  local -r all_knots=$(
    bitcoin-cli \
      --rpcconnect=bitcoincore \
      --rpcport="$BLESK_BITCOINCORE_PORT_RPC" \
      getpeerinfo \
    | \
    jq --raw-output \
      '.[] | select(.subver | contains("Knots")) | {addr: .addr, id: .id}'
  )

  if [[ "$all_knots" ]]; then
    # Iterate over all Knots nodes
    while read -r node; do
      addr=$(<<< "$node" jq -r '.addr')
      id=$(<<< "$node" jq -r '.id')
      base_addr=$(<<< "$addr" cut -d: -f1)

      if [[ "$addr" == *"$BLESK_TOR_IPV6"* ]]; then
        log_with_date "Disconnecting node with addr: ${addr}"
        bitcoin-cli \
          --rpcconnect=bitcoincore \
          --rpcport="$BLESK_BITCOINCORE_PORT_RPC" \
          disconnectnode "" "$id"
      else
        log_with_date "Banning node with addr: ${addr}"
        bitcoin-cli \
          --rpcconnect=bitcoincore \
          --rpcport="$BLESK_BITCOINCORE_PORT_RPC" \
          setban "$base_addr" "add" 1893456000 true
      fi
    done <<< "$(<<< "$all_knots" jq -c '.')"
  else
    log_with_date 'No Knots connected'
  fi

  log_with_date 'Ban script finished'
}

log_with_date 'Starting ban script background process'

(
  while true; do
    sleep 600
    ban_knots
  done
) &

exec bitcoind "${bitcoind_options[@]}"
