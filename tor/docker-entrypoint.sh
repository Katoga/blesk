#!/usr/bin/env bash

set -euo pipefail

envsubst < /tmp/torrc.template > /etc/tor/torrc
chmod 0600 /etc/tor/torrc

exec tor
