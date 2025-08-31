#!/usr/bin/env bash

set -euo pipefail

jq \
  --arg multiPass "$BLESK_RTL_PASSWORD" \
  --arg port "$BLESK_RTL_PORT" \
  --arg macaroonPath "${BLESK_RTL_HOME}/.lnd/data/chain/bitcoin/mainnet/" \
  --arg configPath "${BLESK_RTL_HOME}/.lnd/lnd.conf" \
  --arg lnServerUrl "http://lnd:${BLESK_LND_PORT_REST}" \
  --arg blockExplorerUrl "https://explorer:${BLESK_EXPLORER_PORT_SSL}" \
  '
    .multiPass |= $multiPass
    |
    .port |= $port
    |
    .nodes[0].authentication.macaroonPath |= $macaroonPath
    |
    .nodes[0].authentication.configPath |= $configPath
    |
    .nodes[0].settings.lnServerUrl |= $lnServerUrl
    |
    .nodes[0].settings.blockExplorerUrl |= $blockExplorerUrl
  ' \
  "${BLESK_RTL_HOME}/rtl/Sample-RTL-Config.json" \
  > "${RTL_CONFIG_PATH}/RTL-Config.json"

# jq . ./RTL-Config.json

cd rtl
exec node rtl
