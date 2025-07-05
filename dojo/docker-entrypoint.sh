#!/usr/bin/env bash

set -euo pipefail

node -e " \
    const fs = require('node:fs'); \
    let keys = require('./keys/index-example.js'); \
    keys.default.bitcoin.bitcoind.rpc.host = '[' + process.env.BLESK_BITCOINCORE_IPV6 + ']'; \
    keys.default.bitcoin.bitcoind.rpc.port = process.env.BLESK_BITCOINCORE_PORT_RPC; \
    keys.default.bitcoin.bitcoind.rpc.user = process.env.BLESK_BITCOINCORE_RPC_USER; \
    keys.default.bitcoin.bitcoind.rpc.pass = process.env.BLESK_BITCOINCORE_RPC_PASSWORD; \
    keys.default.bitcoin.bitcoind.zmqTx = 'tcp://[' + process.env.BLESK_BITCOINCORE_IPV6 + ']:' + process.env.BLESK_BITCOINCORE_PORT_ZMQ_TX; \
    keys.default.bitcoin.bitcoind.zmqBlk = 'tcp://[' + process.env.BLESK_BITCOINCORE_IPV6 + ']:' + process.env.BLESK_BITCOINCORE_PORT_ZMQ_BLOCK; \
    keys.default.bitcoin.db.user = process.env.MARIADB_USER; \
    keys.default.bitcoin.db.pass = process.env.MARIADB_PASSWORD; \
    keys.default.bitcoin.db.host = process.env.BLESK_MARIADB_IPV6; \
    keys.default.bitcoin.db.database = process.env.MARIADB_DATABASE; \
    keys.default.bitcoin.auth.mandatory = true; \
    keys.default.bitcoin.auth.strategies.localApiKey.adminKey = process.env.BLESK_DOJO_ADMIN_KEY; \
    keys.default.bitcoin.auth.strategies.localApiKey.apiKeys = [process.env.BLESK_DOJO_API_KEY]; \
    keys.default.bitcoin.auth.jwt.secret = process.env.BLESK_DOJO_JWT_SECRET; \
    keys.default.bitcoin.apiBind = process.env.BLESK_DOJO_IPV6; \
    keys.default.bitcoin.indexer.active = 'local_indexer'; \
    keys.default.bitcoin.indexer.localIndexer.host = process.env.BLESK_ELECTRS_IPV6; \
    keys.default.bitcoin.indexer.localIndexer.port = process.env.BLESK_ELECTRS_PORT; \
    keys.default.bitcoin.indexer.socks5Proxy = 'socks5h://[' + process.env.BLESK_TOR_IPV6 + ']:' + process.env.BLESK_TOR_PORT_SOCKS; \
    keys.default.bitcoin.explorer.active = 'btc_rpc_explorer'; \
    keys.default.bitcoin.explorer.uri = 'http://' + fs.readFileSync(process.env.BLESK_TOR_ONIONS + '/' + process.env.BLESK_EXPLORER_USERNAME + '/hostname', 'utf8').trim(); \
    keys.default.bitcoin.auth.strategies.auth47.hostname = 'http://' + fs.readFileSync(process.env.BLESK_TOR_ONIONS + '/' + process.env.BLESK_DOJO_USERNAME + '/hostname', 'utf8').trim(); \
    keys.default.bitcoin.auth.strategies.auth47.paymentCodes = [process.env.BLESK_DOJO_AUTH47_PAYMENT_CODE]; \
    fs.writeFileSync('./keys/index.js', 'export default ' + JSON.stringify(keys.default, null, 2)); \
  "
# delete keys.default.bitcoin.auth.strategies.auth47; \

chmod 0600 ./keys/index.js

exec pm2-runtime pm2.config.cjs
