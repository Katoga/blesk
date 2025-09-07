#!/usr/bin/env bash

set -euo pipefail

# Mimic LND log message
# BusyBox's date cannot print second's fraction
log_with_date() {
  local -r msg="$1"

  echo "$(date --utc +'%Y-%m-%d %H:%M:%S') [INF] BLSK: ${msg}"
}

scb_backup() {
  local -r source_file="$1"
  local -r local_backup_dir="$2"

  while true; do
    inotifywait \
      --format "%T [SCBB] Watched file '%w' changed (%e)" \
      --timefmt '%Y-%m-%dT%H:%M:%S%z' \
      "$source_file"

    backup_file="${local_backup_dir}/channel-$(date --utc +'%Y%m%d-%H%M%S').backup"

    log_with_date "Creating backup '${backup_file}'"
    cp "$source_file" "${backup_file}"
    log_with_date "Backup '${backup_file}' created"
  done
}

readonly blesk_lnd_wallet_password_file="${BLESK_LND_HOME}/.lnd/wallet_password.txt"
if [[ ! -f "$blesk_lnd_wallet_password_file" ]]; then
  log_with_date 'storing password'
  lnd_password="${BLESK_LND_WALLET_PASSWORD:-}"
  if ! [[ "${lnd_password:-}" ]]; then
    log_with_date 'generating password'
    lnd_password="$(lndinit gen-password)"
  fi

  echo "${lnd_password}" > "$blesk_lnd_wallet_password_file"
  chmod 0600 "$blesk_lnd_wallet_password_file"
  log_with_date 'password stored'
fi

init_wallet_seed_passphrase_arg=''
gen_seed_passphrase_file_arg=''
readonly blesk_lnd_seed_passphrase_file="${BLESK_LND_HOME}/.lnd/seed_passphrase.txt"
if [[ ${BLESK_LND_SEED_PASSPHRASE:-} ]]; then
  log_with_date 'will use seed passphrase'
  init_wallet_seed_passphrase_arg="--file.seed-passphrase=${blesk_lnd_seed_passphrase_file}"
  gen_seed_passphrase_file_arg="--passphrase-file=${blesk_lnd_seed_passphrase_file}"

  if [[ ! -f "$blesk_lnd_seed_passphrase_file" ]]; then
    log_with_date 'storing seed passphrase'
    echo -n "${BLESK_LND_SEED_PASSPHRASE}" > "$blesk_lnd_seed_passphrase_file"
    log_with_date 'seed passphrase stored'
  fi

  chmod 0600 "$blesk_lnd_seed_passphrase_file"
fi

readonly blesk_lnd_seed_file="${BLESK_LND_HOME}/.lnd/seed.txt"
if [[ ! -f "$blesk_lnd_seed_file" ]]; then
  log_with_date 'storing seed'
  lnd_seed="${BLESK_LND_SEED:-}"
  if ! [[ "${lnd_seed:-}" ]]; then
    log_with_date 'generating seed'
    lnd_seed="$(lndinit gen-seed ${gen_seed_passphrase_file_arg})"
  fi

  echo -n "${lnd_seed}" > "$blesk_lnd_seed_file"
  chmod 0600 "$blesk_lnd_seed_file"
  log_with_date 'seed stored'
fi

export blesk_lnd_wallet_password_file
envsubst < "${BLESK_LND_HOME}/lnd.conf.template" > "${BLESK_LND_HOME}/.lnd/lnd.conf"
chmod 0640 "${BLESK_LND_HOME}/.lnd/lnd.conf"
export -n blesk_lnd_wallet_password_file

lndinit init-wallet \
  --file.seed="$blesk_lnd_seed_file" \
  ${init_wallet_seed_passphrase_arg:-} \
  --file.wallet-password="$blesk_lnd_wallet_password_file" \
  --init-file.output-wallet-dir="${BLESK_LND_HOME}/.lnd/data/chain/bitcoin/mainnet" \
  --init-file.validate-password

log_with_date "Seed: '$(cat "$blesk_lnd_seed_file")'"
shred -uz "$blesk_lnd_seed_file"

(
  readonly channel_backup_file="${BLESK_LND_HOME}/.lnd/data/chain/bitcoin/mainnet/channel.backup"
  readonly scb_local_backup_dir="${BLESK_LND_SCB_BACKUP_DIR}"
  scb_backup "$channel_backup_file" "$scb_local_backup_dir"
) &

exec lnd
