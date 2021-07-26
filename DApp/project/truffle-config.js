const HDWalletProvider = require('@truffle/hdwallet-provider')
require('dotenv').config()

const mnemonic = "orange endorse control wrist surface borrow someone pact food view naive salute"
const project = "9e26eee8ea4c498bbeab559b287115b6"

module.exports = {
  networks: {
    kovan: {
      provider: () => {
        return new HDWalletProvider(mnemonic, "https://kovan.infura.io/v3/" + project)
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
