#!/usr/bin/env bash

set -euo pipefail

tor_options=(
  --ClientPreferIPv6ORPort 1

  --SocksPort "[${BLESK_TOR_IPV6}]:${BLESK_TOR_PORT_SOCKS}"
  --SocksPort "${BLESK_TOR_IPV4}:${BLESK_TOR_PORT_SOCKS}"

  --SocksPolicy "accept ${BLESK_NET_INTERNAL_IPV6}"
  --SocksPolicy "accept ${BLESK_NET_INTERNAL_IPV4}"
  --SocksPolicy "reject *"

  --DataDirectory "${BLESK_TOR_HOME}/.tor"
  --DataDirectoryGroupReadable 1

  --CookieAuthentication 1

  --ControlPort "$BLESK_TOR_PORT_CONTROL"

  # bitcoincore
  --HiddenServiceDir "${BLESK_TOR_ONIONS}/${BLESK_BITCOINCORE_USERNAME}"
  --HiddenServiceVersion 3
  --HiddenServicePort "${BLESK_BITCOINCORE_PORT_P2P} [${BLESK_BITCOINCORE_IPV6}]:${BLESK_BITCOINCORE_PORT_P2P}"
  --HiddenServiceDirGroupReadable 1

  # electrs
  --HiddenServiceDir "${BLESK_TOR_ONIONS}/${BLESK_ELECTRS_USERNAME}"
  --HiddenServiceVersion 3
  --HiddenServicePort "${BLESK_ELECTRS_PORT} [${BLESK_ELECTRS_IPV6}]:${BLESK_ELECTRS_PORT}"
  --HiddenServiceDirGroupReadable 1
)

exec tor "${tor_options[@]}"
