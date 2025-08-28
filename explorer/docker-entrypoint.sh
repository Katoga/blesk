#!/usr/bin/env bash

set -euo pipefail

envsubst < /etc/btc-rpc-explorer/.env.template > /etc/btc-rpc-explorer/.env
chmod 0600 /etc/btc-rpc-explorer/.env
rm -f /etc/btc-rpc-explorer/.env.template

exec ./explorer/bin/cli.js
