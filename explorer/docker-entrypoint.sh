#!/usr/bin/env bash

set -euo pipefail

explorer_options=(
  --privacy-mode
  --no-rates
  --coin="BTC"

  --host="$BLESK_EXPLORER_IPV6"
  --port="$BLESK_EXPLORER_PORT"

  --bitcoind-host="$BLESK_BITCOINCORE_IPV6"
  --bitcoind-port="$BLESK_BITCOINCORE_PORT_RPC"
  --bitcoind-user="$BLESK_BITCOINCORE_RPC_USER"
  --bitcoind-pass="$BLESK_BITCOINCORE_RPC_PASSWORD"

  --address-api="electrum"
  --electrum-servers="tcp://[${BLESK_ELECTRS_IPV6}]:${BLESK_ELECTRS_PORT}"

  --slow-device-mode="${BLESK_EXPLORER_SLOW_DEVICE_MODE}"
)

exec ./bin/cli.js "${explorer_options[@]}"
