#!/usr/bin/env bash

set -euo pipefail

readonly conf_file="${BLESK_ELECTRS_HOME}/electrs.toml"
touch "$conf_file"
chmod 0640 "$conf_file"
echo "auth = \"${BLESK_BITCOINCORE_RPC_USER}:${BLESK_BITCOINCORE_RPC_PASSWORD}\"" > "$conf_file"

indexer_options=(
  # Bitcoin Core settings
  --daemon-rpc-addr="[${BLESK_BITCOINCORE_IPV6}]:${BLESK_BITCOINCORE_PORT_RPC}"
  --daemon-p2p-addr="[${BLESK_BITCOINCORE_IPV6}]:${BLESK_BITCOINCORE_PORT_P2P}"

  # Electrs settings
  --electrum-rpc-addr="${BLESK_ELECTRS_IPV6}:${BLESK_ELECTRS_PORT}"
  --db-dir="${BLESK_ELECTRS_HOME}/db"

  # Logging
  --log-filters="INFO"

  # Index
  --index-lookup-limit="$BLESK_ELECTRS_LOOKUP_LIMIT"
  --index-batch-size="$BLESK_ELECTRS_BATCH_SIZE"
)

exec electrs "${indexer_options[@]}"
