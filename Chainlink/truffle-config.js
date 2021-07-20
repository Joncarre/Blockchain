const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = "orange endorse control wrist surface borrow someone pact food view naive salute";
const projectID = "9e26eee8ea4c498bbeab559b287115b6";

module.exports = {
  networks: {
    kovan: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://kovan.infura.io/v3/" + projectID);
      },
      network_id: 42,
      gasPrice: 20000000000,
      gas: 3716887
    },
   },
   compilers: {
    solc: {
      version: "^0.6",    // Fetch exact version from solc-bin (default: truffle's version)
    }
  }
 };
