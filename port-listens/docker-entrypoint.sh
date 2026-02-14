#!/usr/bin/env bash

set -euo pipefail

log_with_date() {
  local -r msg="$1"

  echo "$(date --utc +'%Y-%m-%d %H:%M:%S'): ${msg}"
}

main() {
	local -r watched_host="$1"
	local -r watched_port="$2"

	log_with_date "Waiting for port '${watched_port}' on '${watched_host}' to be listening."

	while ! nc -zvw 10 -6 "${watched_host}" "${watched_port}" > /dev/null 2>&1; do
		sleep 1
	done

	log_with_date "Port '${watched_port}' on '${watched_host}' is listening."
}

(return 0 2> /dev/null) || main "$@"
