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

exec bitcoind "${bitcoind_options[@]}"
