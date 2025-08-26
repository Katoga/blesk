#!/usr/bin/env bash

set -euo pipefail

envsubst < /etc/tor/torrc.template > /etc/tor/torrc

exec tor
