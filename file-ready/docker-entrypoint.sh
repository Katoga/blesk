#!/usr/bin/env bash

set -euo pipefail

log_with_date() {
  local -r msg="$1"

  echo "$(date --utc +'%Y-%m-%d %H:%M:%S'): ${msg}"
}

main() {
	local -r watched_file_fullpath="$1"

	local -r watched_dir="$(dirname "${watched_file_fullpath}")"
	local -r watched_file="$(basename "${watched_file_fullpath}")"

	log_with_date "Waiting for '${watched_file}' to be in '${watched_dir}'."

	[[ -e "$watched_file_fullpath" ]] || inotifywait -qq -e create --include "$watched_file" "$watched_dir"

	log_with_date "File '${watched_file}' is in '${watched_dir}'."
}

(return 0 2> /dev/null) || main "$@"
