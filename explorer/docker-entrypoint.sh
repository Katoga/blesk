#!/usr/bin/env bash

set -euo pipefail

envsubst < /etc/btc-rpc-explorer/.env.template > /etc/btc-rpc-explorer/.env
chmod 0600 /etc/btc-rpc-explorer/.env

exec ./explorer/bin/cli.js
