#!/usr/bin/env bash

set -euo pipefail

envsubst < /etc/electrs/config.toml.template > /etc/electrs/config.toml
chmod 0640 /etc/electrs/config.toml

exec electrs
