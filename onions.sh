#!/usr/bin/env bash

set -euo pipefail

docker compose exec tor bash -c 'for o in $(ls ${BLESK_TOR_ONIONS}); do echo "${o}: $(cat ${BLESK_TOR_ONIONS}/${o}/hostname)"; done'
