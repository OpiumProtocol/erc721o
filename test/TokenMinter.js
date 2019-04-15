const TokenMinter = artifacts.require('TokenMinter')

const { calculatePortfolioId } = require('./utils/positions')

contract('TokenMinter', accounts => {
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const charlie = accounts[3]

    let tokenMinter

    let portfolioIdOneOneOne, portfolioIdOneTwoThree

    let transferFromFour = 'transferFrom(address,address,uint256,uint256)'
    let batchTransferFromFour = 'batchTransferFrom(address,address,uint256[],uint256[])'

    before(async () => {
        // Deploy
        tokenMinter = await TokenMinter.deployed()

        // Prepare
        const gas = await tokenMinter.mint.estimateGas(1, alice, 10, { from: owner })
        tokenMinter.mint(1, alice, 10, { from: owner })
        console.log('Gas used during minting =', gas)
        tokenMinter.mint(2, alice, 20, { from: owner })
        tokenMinter.mint(3, alice, 30, { from: owner })
    })

    context('Balance', () => {
        it('should correctly return balance', async () => {
            const totalBalance = await tokenMinter.balanceOf(alice)
            const balanceOne = await tokenMinter.balanceOf(alice, 1)
            const balanceTwo = await tokenMinter.balanceOf(alice, 2)
            const balanceThree = await tokenMinter.balanceOf(alice, 3)

            assert.equal(totalBalance, 3, 'Total balance is wrong')
            assert.equal(balanceOne, 10, 'Balance one is wrong')
            assert.equal(balanceTwo, 20, 'Balance two is wrong')
            assert.equal(balanceThree, 30, 'Balance three is wrong')
        })  
    })

    context('Transfer', () => {
        it('should successfully transfer single tokenId', async () => {
            const gas = await tokenMinter.methods[transferFromFour].estimateGas(alice, bob, 1, 5, { from: alice })
            console.log('Gas used during single transfer =', gas)
            await tokenMinter.methods[transferFromFour](alice, bob, 1, 5, { from: alice })

            const aliceBalance = await tokenMinter.balanceOf(alice, 1)
            const bobBalance = await tokenMinter.balanceOf(bob, 1)

            assert.equal(aliceBalance, 5, 'Alice balance is wrong')
            assert.equal(bobBalance, 5, 'Bob balance is wrong')
        })

        it('should successfully batch transfer', async () => {
            const gas = await tokenMinter.methods[batchTransferFromFour].estimateGas(alice, charlie, [2, 3], [5, 5], { from: alice })
            console.log('Gas used during batch transfer =', gas)
            await tokenMinter.methods[batchTransferFromFour](alice, charlie, [2, 3], [5, 5], { from: alice })

            const aliceBalanceTwo = await tokenMinter.balanceOf(alice, 2)
            const aliceBalanceThree = await tokenMinter.balanceOf(alice, 3)
            const charlieBalanceTwo = await tokenMinter.balanceOf(charlie, 2)
            const charlieBalanceThree = await tokenMinter.balanceOf(charlie, 3)

            assert.equal(aliceBalanceTwo, 15, 'Alice balance two is wrong')
            assert.equal(aliceBalanceThree, 25, 'Alice balance three is wrong')
            assert.equal(charlieBalanceTwo, 5, 'Charlie balance two is wrong')
            assert.equal(charlieBalanceThree, 5, 'Charlie balance three is wrong')
        })
    })

    context('Composition', () => {
        it('should successfully compose three tokenIds into one portfolio', async () => {
            const gas = await tokenMinter.compose.estimateGas([1, 2, 3], [1, 1, 1], 5, { from: alice })
            console.log('Gas used during composition =', gas)
            await tokenMinter.compose([1, 2, 3], [1, 1, 1], 5, { from: alice })

            portfolioIdOneOneOne = calculatePortfolioId([1, 2, 3], [1, 1, 1])

            const aliceBalanceOne = await tokenMinter.balanceOf(alice, 1)
            const aliceBalanceTwo = await tokenMinter.balanceOf(alice, 2)
            const aliceBalanceThree = await tokenMinter.balanceOf(alice, 3)
            const aliceBalancePortfolio = await tokenMinter.balanceOf(alice, portfolioIdOneOneOne)

            assert.equal(aliceBalanceOne, 0, 'Alice balance one is wrong')
            assert.equal(aliceBalanceTwo, 10, 'Alice balance two is wrong')
            assert.equal(aliceBalanceThree, 20, 'Alice balance three is wrong')
            assert.equal(aliceBalancePortfolio, 5, 'Alice balance portfolio is wrong')
        })

        it('should successfully recompose three tokenIds with ratio 1:1:1 into ratio 1:2:3', async () => {
            const gas = await tokenMinter.recompose.estimateGas(portfolioIdOneOneOne, [1, 2, 3], [1, 1, 1], [1, 2, 3], [1, 2, 3], 5, { from: alice })
            console.log('Gas used during recomposition =', gas)
            await tokenMinter.recompose(portfolioIdOneOneOne, [1, 2, 3], [1, 1, 1], [1, 2, 3], [1, 2, 3], 5, { from: alice })

            portfolioIdOneTwoThree = calculatePortfolioId([1, 2, 3], [1, 2, 3])

            const aliceBalanceOne = await tokenMinter.balanceOf(alice, 1)
            const aliceBalanceTwo = await tokenMinter.balanceOf(alice, 2)
            const aliceBalanceThree = await tokenMinter.balanceOf(alice, 3)
            const aliceBalancePortfolioOne = await tokenMinter.balanceOf(alice, portfolioIdOneOneOne)
            const aliceBalancePortfolioTwo = await tokenMinter.balanceOf(alice, portfolioIdOneTwoThree)

            assert.equal(aliceBalanceOne, 0, 'Alice balance one is wrong')
            assert.equal(aliceBalanceTwo, 5, 'Alice balance two is wrong')
            assert.equal(aliceBalanceThree, 10, 'Alice balance three is wrong')
            assert.equal(aliceBalancePortfolioOne, 0, 'Alice balance portfolio one is wrong')
            assert.equal(aliceBalancePortfolioTwo, 5, 'Alice balance portfolio two is wrong')
        })

        it('should successfully decompose three tokenIds with ratio 1:2:3', async () => {
            const gas = await tokenMinter.decompose.estimateGas(portfolioIdOneTwoThree, [1, 2, 3], [1, 2, 3], 5, { from: alice })
            console.log('Gas used during decomposition =', gas)
            await tokenMinter.decompose(portfolioIdOneTwoThree, [1, 2, 3], [1, 2, 3], 5, { from: alice })

            const aliceBalanceOne = await tokenMinter.balanceOf(alice, 1)
            const aliceBalanceTwo = await tokenMinter.balanceOf(alice, 2)
            const aliceBalanceThree = await tokenMinter.balanceOf(alice, 3)
            const aliceBalancePortfolioTwo = await tokenMinter.balanceOf(alice, portfolioIdOneTwoThree)

            assert.equal(aliceBalanceOne, 5, 'Alice balance one is wrong')
            assert.equal(aliceBalanceTwo, 15, 'Alice balance two is wrong')
            assert.equal(aliceBalanceThree, 25, 'Alice balance three is wrong')
            assert.equal(aliceBalancePortfolioTwo, 0, 'Alice balance portfolio two is wrong')
        })

        it('should successfully composition of 10 different tokenIds with ratio 1:1', async () => {
            const size = 10
            const tokenIds = []
            const tokenRatio = []
            let i = 0
            while (i < size) {
                const tokenId = 100 + i++
                tokenIds.push(tokenId)
                tokenRatio.push(1)
                await tokenMinter.mint(tokenId, charlie, 1)
            }

            const gas = await tokenMinter.compose.estimateGas(tokenIds, tokenRatio, 1, { from: charlie })
            console.log('Gas used during composition of 10 different tokenIds =', gas)
            await tokenMinter.compose(tokenIds, tokenRatio, 1, { from: charlie })
        })

        it('should successfully composition of 50 different tokenIds with ratio 1:1', async () => {
            const size = 50
            const tokenIds = []
            const tokenRatio = []
            let i = 0
            while (i < size) {
                const tokenId = 200 + i++
                tokenIds.push(tokenId)
                tokenRatio.push(1)
                await tokenMinter.mint(tokenId, charlie, 1)
            }

            const gas = await tokenMinter.compose.estimateGas(tokenIds, tokenRatio, 1, { from: charlie })
            console.log('Gas used during composition of 50 different tokenIds =', gas)
            await tokenMinter.compose(tokenIds, tokenRatio, 1, { from: charlie })
        })

        it('should successfully composition of 100 different tokenIds with ratio 1:1', async () => {
            const size = 100
            const tokenIds = []
            const tokenRatio = []
            let i = 0
            while (i < size) {
                const tokenId = 300 + i++
                tokenIds.push(tokenId)
                tokenRatio.push(1)
                await tokenMinter.mint(tokenId, charlie, 1)
            }

            const gas = await tokenMinter.compose.estimateGas(tokenIds, tokenRatio, 1, { from: charlie })
            console.log('Gas used during composition of 100 different tokenIds =', gas)
            await tokenMinter.compose(tokenIds, tokenRatio, 1, { from: charlie })
        })
    })
})