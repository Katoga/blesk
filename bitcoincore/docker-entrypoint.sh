#!/usr/bin/env bash

set -euo pipefail

# Prevent excessive memory usage
export MALLOC_ARENA_MAX=1

# Generate RPC auth payload
BITCOIND_RPC_AUTH=$(rpcauth "$BLESK_BITCOINCORE_RPC_USER" "$BLESK_BITCOINCORE_RPC_PASSWORD" 2> /dev/null)

bitcoind_options=(
  # Bitcoin daemon
  -server=1
  -txindex=1

  # Network
  -listen=1
  -bind="$BLESK_BITCOINCORE_IPV6"
  -port="$BLESK_BITCOINCORE_PORT_P2P"
  -dns=0
  -dnsseed=0

  # TOR
  -proxy="[${BLESK_TOR_IPV6}]:${BLESK_TOR_PORT_SOCKS}"
  -externalip="$(cat "${BLESK_TOR_ONIONS}/${BLESK_BITCOINCORE_USERNAME}/hostname")"

  # Connections
  -rpcallowip="$BLESK_NET_INTERNAL_IPV6"
  -rpcbind="$BLESK_BITCOINCORE_IPV6"
  -rpcport="$BLESK_BITCOINCORE_PORT_RPC"
  -rpcauth="$BITCOIND_RPC_AUTH"
  -zmqpubrawblock="tcp://[${BLESK_BITCOINCORE_IPV6}]:${BLESK_BITCOINCORE_PORT_ZMQ_BLOCK}"
  -zmqpubrawtx="tcp://[${BLESK_BITCOINCORE_IPV6}]:${BLESK_BITCOINCORE_PORT_ZMQ_TX}"

  # RPi optimizations
  -maxconnections="$BLESK_BITCOINCORE_MAX_CONNECTIONS"
  -maxuploadtarget="$BLESK_BITCOINCORE_MAX_UPLOAD_TARGET"
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
      --rpcconnect="$BLESK_BITCOINCORE_IPV6" \
      --rpcport="$BLESK_BITCOINCORE_PORT_RPC" \
      --rpcuser="$BLESK_BITCOINCORE_RPC_USER" \
      --rpcpassword="$BLESK_BITCOINCORE_RPC_PASSWORD" \
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
          --rpcconnect="$BLESK_BITCOINCORE_IPV6" \
          --rpcport="$BLESK_BITCOINCORE_PORT_RPC" \
          --rpcuser="$BLESK_BITCOINCORE_RPC_USER" \
          --rpcpassword="$BLESK_BITCOINCORE_RPC_PASSWORD" \
          disconnectnode "" "$id"
      else
        log_with_date "Banning node with addr: ${addr}"
        bitcoin-cli \
          --rpcconnect="$BLESK_BITCOINCORE_IPV6" \
          --rpcport="$BLESK_BITCOINCORE_PORT_RPC" \
          --rpcuser="$BLESK_BITCOINCORE_RPC_USER" \
          --rpcpassword="$BLESK_BITCOINCORE_RPC_PASSWORD" \
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
