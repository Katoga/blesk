const path = require('path')

const NAMESPACE = 'mainnet'
const INTERPRETER = '/nodejs/bin/node'

module.exports = {
  apps: [
    {
      name: `Samourai Dojo - Accounts (${NAMESPACE})`,
      namespace: NAMESPACE,
      script: './index.js',
      cwd: path.join(__dirname, 'accounts'),
      interpreter: INTERPRETER,
      out_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './accounts-output.log'),
      error_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './accounts-error.log'),
      wait_ready: true,
      stop_exit_codes: 0,
      listen_timeout: 5000,
      kill_timeout: 3000,
    },
    {
      name: `Samourai Dojo - PushTX (${NAMESPACE})`,
      namespace: NAMESPACE,
      script: './index.js',
      cwd: path.join(__dirname, 'pushtx'),
      interpreter: INTERPRETER,
      out_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './pushtx-output.log'),
      error_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './pushtx-error.log'),
      wait_ready: true,
      stop_exit_codes: 0,
      listen_timeout: 5000,
      kill_timeout: 3000,
    },
    {
      name: `Samourai Dojo - PushTX orchestrator (${NAMESPACE})`,
      namespace: NAMESPACE,
      script: './index-orchestrator.js',
      cwd: path.join(__dirname, 'pushtx'),
      interpreter: INTERPRETER,
      out_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './orchestrator-output.log'),
      error_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './orchestrator-error.log'),
      wait_ready: true,
      stop_exit_codes: 0,
      listen_timeout: 5000,
      kill_timeout: 3000,
    },
    {
      name: `Samourai Dojo - Tracker (${NAMESPACE})`,
      namespace: NAMESPACE,
      script: './index.js',
      cwd: path.join(__dirname, 'tracker'),
      interpreter: INTERPRETER,
      out_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './tracker-output.log'),
      error_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './tracker-error.log'),
      wait_ready: true,
      stop_exit_codes: 0,
      listen_timeout: 5000,
      kill_timeout: 3000,
    },
    {
      name: `Samourai Dojo - Estimator (${NAMESPACE})`,
      namespace: NAMESPACE,
      script: './index.js',
      cwd: path.join(__dirname, 'estimator'),
      interpreter: INTERPRETER,
      out_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './estimator-output.log'),
      error_file: path.join(process.env.BLESK_DOJO_LOGS_DIR, './estimator-error.log'),
      wait_ready: true,
      stop_exit_codes: 0,
      listen_timeout: 5000,
      kill_timeout: 3000,
    }
  ]
}
