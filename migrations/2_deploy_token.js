const TokenMinter = artifacts.require('TokenMinter')

const baseTokenURI = "https://explorer.opium.nework/erc721xo/"

module.exports = async function(deployer, network, accounts) {
  const owner = accounts[0]

  let tokenMinter

  deployer.deploy(TokenMinter, baseTokenURI, { from: owner })
    .then(instance => {
      tokenMinter = instance
      console.log('--- TokenMinter was deployed at', tokenMinter.address)
    })
}
