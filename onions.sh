#!/usr/bin/env bash


set -euo pipefail

docker run -t --rm -v blesk_data-tor:/srv/tor:ro --workdir /srv/tor alpine:3 sh -c 'for o in $(ls | grep ^onion_); do echo "${o}: $(cat ${o}/hostname)"; done'
