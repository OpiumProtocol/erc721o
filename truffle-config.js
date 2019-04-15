module.exports = {
  plugins: [ 'truffle-security' ],
  networks: {
    development: {
     host: "127.0.0.1",
     port: 9545,
     network_id: "*",
    },
    ganache: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
     },
    coverage: {
      host: "localhost",
      network_id: "*",
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.5.7",
      settings: {
       optimizer: {
         enabled: false,
         runs: 200
       },
      }
    }
  }
}
