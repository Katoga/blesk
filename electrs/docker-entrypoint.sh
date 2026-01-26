#!/usr/bin/env bash

set -euo pipefail

envsubst < /tmp/config.toml.template > /etc/electrs/config.toml
chmod 0600 /etc/electrs/config.toml

exec electrs
