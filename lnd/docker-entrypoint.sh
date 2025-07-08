#!/usr/bin/env bash

set -euo pipefail

readonly password_file="${BLESK_LND_HOME}/.lnd/password.txt"
if [[ ! -f "$password_file" ]]; then
  echo "${BLESK_LND_PASSWORD}" > "$password_file"
fi

lnd_options=(
  --listen="[${BLESK_LND_IPV6}]:${BLESK_LND_PORT_P2P}"
  --rpclisten="localhost:${BLESK_LND_PORT_RPC}"
  --rpclisten="[${BLESK_LND_IPV6}]:${BLESK_LND_PORT_RPC}"
  --restlisten="[${BLESK_LND_IPV6}]:${BLESK_LND_PORT_REST}"
  --alias="$BLESK_LND_ALIAS"
  --debuglevel=info
  --maxpendingchannels=5
  --wallet-unlock-password-file="$password_file"
  --wallet-unlock-allow-create true
  --tlsautorefresh true
  --tlsdisableautofill true
  --minchansize=100000
  --accept-keysend true
  --accept-amp true
  --coop-close-target-confs=24
  --gc-canceled-invoices-on-startup true
  --gc-canceled-invoices-on-the-fly true
  --ignore-historical-gossip-filters true
  --stagger-initial-reconnect true

  --wtclient.active true

  --protocol.wumbo-channels true
  --protocol.simple-taproot-chans true

  --bitcoin.mainnet true
  --bitcoin.node=bitcoind

  --db.bolt.auto-compact true
  --db.bolt.auto-compact-min-age=168h

  --bitcoind.rpchost="bitcoincore:${BLESK_BITCOINCORE_PORT_RPC}"
  --bitcoind.rpcuser="$BLESK_BITCOINCORE_RPC_USER"
  --bitcoind.rpcpass="$BLESK_BITCOINCORE_RPC_PASSWORD"
  --bitcoind.zmqpubrawblock="tcp://bitcoincore:${BLESK_BITCOINCORE_PORT_ZMQ_BLOCK}"
  --bitcoind.zmqpubrawtx="tcp://bitcoincore:${BLESK_BITCOINCORE_PORT_ZMQ_TX}"

  --tor.active true
  --tor.streamisolation true
  --tor.v3 true
  --tor.socks="${BLESK_TOR_IPV6}"
  --tor.control="${BLESK_TOR_IPV6}"
  --tor.targetipaddress="${BLESK_LND_IPV6}"
)

exec lnd "${lnd_options[@]}"
