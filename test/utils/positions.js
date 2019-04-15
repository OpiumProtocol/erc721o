module.exports.calculatePortfolioId = (tokenIds, tokenRatio) => {
  return web3.utils.soliditySha3(
    {
        type: 'uint256[]',
        value: tokenIds
    },
    {
        type: 'uint256[]',
        value: tokenRatio
    }
  )
}
