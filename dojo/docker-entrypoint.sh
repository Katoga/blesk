#!/usr/bin/env bash

set -euo pipefail

node -e " \
    const fs = require('node:fs'); \
    let keys = require(process.env.BLESK_DOJO_HOME + '/index-example.js'); \
    keys.default.bitcoin.bitcoind.rpc.host = 'bitcoincore'; \
    keys.default.bitcoin.bitcoind.rpc.port = process.env.BLESK_BITCOINCORE_PORT_RPC; \
    keys.default.bitcoin.bitcoind.rpc.user = ''; \
    keys.default.bitcoin.bitcoind.rpc.pass = ''; \
    keys.default.bitcoin.bitcoind.rpc.cookie_path = process.env.BLESK_DOJO_HOME + '/.bitcoin/.cookie'; \
    keys.default.bitcoin.bitcoind.zmqTx = 'tcp://bitcoincore:' + process.env.BLESK_BITCOINCORE_PORT_ZMQ_TX; \
    keys.default.bitcoin.bitcoind.zmqBlk = 'tcp://bitcoincore:' + process.env.BLESK_BITCOINCORE_PORT_ZMQ_BLOCK; \
    keys.default.bitcoin.ports.account = process.env.BLESK_DOJO_PORT_API; \
    keys.default.bitcoin.ports.pushtx = process.env.BLESK_DOJO_PORT_PUSHTX; \
    keys.default.bitcoin.ports.trackerApi = process.env.BLESK_DOJO_PORT_TRACKER; \
    keys.default.bitcoin.db.user = process.env.MARIADB_USER; \
    keys.default.bitcoin.db.pass = process.env.MARIADB_PASSWORD; \
    keys.default.bitcoin.db.host = 'mariadb'; \
    keys.default.bitcoin.db.database = process.env.MARIADB_DATABASE; \
    keys.default.bitcoin.auth.mandatory = true; \
    keys.default.bitcoin.auth.strategies.localApiKey.adminKey = process.env.BLESK_DOJO_ADMIN_KEY; \
    keys.default.bitcoin.auth.strategies.localApiKey.apiKeys = [process.env.BLESK_DOJO_API_KEY]; \
    keys.default.bitcoin.auth.jwt.secret = process.env.BLESK_DOJO_JWT_SECRET; \
    keys.default.bitcoin.apiBind = 'dojo'; \
    keys.default.bitcoin.indexer.active = 'local_indexer'; \
    keys.default.bitcoin.indexer.localIndexer.host = 'electrs'; \
    keys.default.bitcoin.indexer.localIndexer.port = process.env.BLESK_ELECTRS_PORT; \
    keys.default.bitcoin.indexer.socks5Proxy = 'socks5h://[' + process.env.BLESK_TOR_IPV6 + ']:' + process.env.BLESK_TOR_PORT_SOCKS; \
    keys.default.bitcoin.explorer.active = 'btc_rpc_explorer'; \
    keys.default.bitcoin.explorer.uri = 'http://' + fs.readFileSync(process.env.BLESK_TOR_ONIONS + '/' + process.env.BLESK_EXPLORER_USERNAME + '/hostname', 'utf8').trim(); \
    keys.default.bitcoin.auth.strategies.auth47.hostname = 'http://' + fs.readFileSync(process.env.BLESK_TOR_ONIONS + '/' + process.env.BLESK_DOJO_USERNAME + '/hostname', 'utf8').trim(); \
    keys.default.bitcoin.auth.strategies.auth47.paymentCodes = [process.env.BLESK_DOJO_AUTH47_PAYMENT_CODE]; \
    fs.writeFileSync('./dojo/keys/index.js', 'export default ' + JSON.stringify(keys.default, null, 2)); \
  "
# delete keys.default.bitcoin.auth.strategies.auth47; \

chmod 0600 ./dojo/keys/index.js

cd dojo
exec pm2-runtime pm2.config.cjs
