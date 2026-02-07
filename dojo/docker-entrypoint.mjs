#!/nodejs/bin/node

// create config
import { readFileSync, writeFileSync } from 'node:fs'
import keys from '/home/nonroot/dojo/index-example.js';
const nonroot_home = '/home/nonroot';
const dojo_root = nonroot_home + '/dojo';
const tor_root = nonroot_home + '/.tor';

keys.bitcoin.bitcoind.rpc.host = 'bitcoincore';
keys.bitcoin.bitcoind.rpc.port = process.env.BLESK_BITCOINCORE_PORT_RPC;
keys.bitcoin.bitcoind.rpc.user = '';
keys.bitcoin.bitcoind.rpc.pass = '';
keys.bitcoin.bitcoind.rpc.cookie_path = process.env.BLESK_BITCOINCORE_COOKIE_DIR + '/.cookie';
keys.bitcoin.bitcoind.zmqTx = 'tcp://bitcoincore:' + process.env.BLESK_BITCOINCORE_PORT_ZMQ_TX;
keys.bitcoin.bitcoind.zmqBlk = 'tcp://bitcoincore:' + process.env.BLESK_BITCOINCORE_PORT_ZMQ_BLOCK;
keys.bitcoin.ports.account = process.env.BLESK_DOJO_PORT_API;
keys.bitcoin.ports.pushtx = process.env.BLESK_DOJO_PORT_PUSHTX;
keys.bitcoin.ports.trackerApi = process.env.BLESK_DOJO_PORT_TRACKER;
keys.bitcoin.db.user = process.env.MARIADB_USER;
keys.bitcoin.db.pass = process.env.MARIADB_PASSWORD;
keys.bitcoin.db.host = 'mariadb';
keys.bitcoin.db.database = process.env.MARIADB_DATABASE;
keys.bitcoin.auth.mandatory = true;
keys.bitcoin.auth.strategies.localApiKey.adminKey = process.env.BLESK_DOJO_ADMIN_KEY;
keys.bitcoin.auth.strategies.localApiKey.apiKeys = [process.env.BLESK_DOJO_API_KEY];
keys.bitcoin.auth.jwt.secret = process.env.BLESK_DOJO_JWT_SECRET;
keys.bitcoin.apiBind = 'dojo';
keys.bitcoin.indexer.active = 'local_indexer';
keys.bitcoin.indexer.localIndexer.host = 'electrs';
keys.bitcoin.indexer.localIndexer.port = process.env.BLESK_ELECTRS_PORT;
keys.bitcoin.indexer.socks5Proxy = 'socks5h://[' + process.env.BLESK_TOR_IPV6 + ']:' + process.env.BLESK_TOR_PORT_SOCKS;
keys.bitcoin.explorer.active = 'btc_rpc_explorer';
keys.bitcoin.explorer.uri = 'http://' + readFileSync(tor_root + '/onion_explorer/hostname', 'utf8').trim();
keys.bitcoin.auth.strategies.auth47.hostname = 'http://' + readFileSync(tor_root + '/onion_dojo/hostname', 'utf8').trim();
keys.bitcoin.auth.strategies.auth47.paymentCodes = [process.env.BLESK_DOJO_AUTH47_PAYMENT_CODE];
keys.bitcoin.pm2_node_modules_root = dojo_root + '/node_modules';
delete keys.testnet;
writeFileSync(dojo_root + '/keys/index.js', 'export default ' + JSON.stringify(keys, null, 2));

// start the app
import { spawn } from 'node:child_process';
import { once } from 'node:events';
const cmd = spawn('/home/nonroot/dojo/node_modules/.bin/pm2-runtime', ['/home/nonroot/dojo/pm2.config.cjs'], {shell: false});

cmd.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

cmd.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

const [code] = await once(cmd, 'close');
console.log(`child process exited with code ${code}`);
