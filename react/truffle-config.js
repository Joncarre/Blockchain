const { mnemonic, projectId } = require('./secrets.json');
const HDWalletProvider = require('@truffle/hdwallet-provider')
require('dotenv').config()

module.exports = {
  networks: {
    kovan: {
      provider: () => {
        return new HDWalletProvider(mnemonic, `https://kovan.infura.io/v3/${projectId}`)
      },
      network_id: '42',
      skipDryRun: true,
      networkCheckTimeout: 8000000,
      timeoutBlocks: 4000
    },
  },
  compilers: {
    solc: {
      version: '0.6.6',
    },
  },
}
