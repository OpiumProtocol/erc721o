const TokenMinter = artifacts.require('TokenMinter')

// Utils
const { calculatePortfolioId } = require('./utils/positions')
const permits = require('./utils/permits')

const zeroAddress = '0x0000000000000000000000000000000000000000'

contract('TokenMinter', accounts => {
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const charlie = accounts[3]

    let tokenMinter

    let portfolioIdOneOneOne, portfolioIdOneTwoThree

    let transferFromFour = 'transferFrom(address,address,uint256,uint256)'
    let batchTransferFromFour = 'batchTransferFrom(address,address,uint256[],uint256[])'

    let permitFactory

    before(async () => {
        // Deploy
        tokenMinter = await TokenMinter.deployed()

        // Prepare
        tokenMinter.mint(1, alice, 10, { from: owner })
        tokenMinter.mint(2, alice, 20, { from: owner })
        tokenMinter.mint(3, alice, 30, { from: owner })

        permitFactory = permit => permits.permitFactory({ permit, minter: tokenMinter })
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
        it('should revert transferFrom by not approved actor', async () => {
            try {
                await tokenMinter.methods[transferFromFour](alice, bob, 1, 5, { from: bob })
                throw null
            } catch (e) {
                assert.ok(e.message.match(/Not approved/), 'Not approved')
            }
        })

        it('should successfully transfer single tokenId', async () => {
            await tokenMinter.methods[transferFromFour](alice, bob, 1, 5, { from: alice })

            const aliceBalance = await tokenMinter.balanceOf(alice, 1)
            const bobBalance = await tokenMinter.balanceOf(bob, 1)

            assert.equal(aliceBalance, 5, 'Alice balance is wrong')
            assert.equal(bobBalance, 5, 'Bob balance is wrong')
        })

        it('should revert batchTransferFrom by not approved actor', async () => {
            try {
                await tokenMinter.methods[batchTransferFromFour](alice, charlie, [2, 3], [5, 5], { from: charlie })
                throw null
            } catch (e) {
                assert.ok(e.message.match(/msg.sender is neither _from nor operator/), 'msg.sender is neither _from nor operator')
            }
        })

        it('should successfully batch transfer', async () => {
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

        it('should revert transfer to zero address', async () => {
            await tokenMinter.mint(1337, alice, 10, { from: owner })

            try {
                await tokenMinter.methods[transferFromFour](alice, zeroAddress, 1337, 5, { from: alice })
                throw null
            } catch (e) {
                assert.ok(e.message.match(/Invalid to address/), 'Invalid to address')
            }

            try {
                await tokenMinter.methods[batchTransferFromFour](alice, zeroAddress, [1337], [5], { from: alice })
                throw null
            } catch (e) {
                assert.ok(e.message.match(/Invalid to address/), 'Invalid to address')
            }
        })

        it('should successfully transfer to itself', async () => {
            await tokenMinter.methods[transferFromFour](alice, alice, 1337, 5, { from: alice })
            const aliceBalance1337AfterOne = await tokenMinter.balanceOf(alice, 1337)
            assert.equal(aliceBalance1337AfterOne, 10, 'Alice balance 1337 is wrong')

            await tokenMinter.methods[batchTransferFromFour](alice, alice, [1337], [5], { from: alice })
            const aliceBalance1337AfterTwo = await tokenMinter.balanceOf(alice, 1337)
            assert.equal(aliceBalance1337AfterTwo, 10, 'Alice balance 1337 is wrong')
          })
    })

    context('Composition', () => {
        it('should successfully compose three tokenIds into one portfolio', async () => {
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

            await tokenMinter.compose(tokenIds, tokenRatio, 1, { from: charlie })
        })
    })

    context('Approval', () => {
        it('should revert unapproved transfer', async () => {
            try {
                await tokenMinter.methods[transferFromFour](alice, bob, 1, 5, { from: bob })
                throw null
            } catch (e) {
                assert.ok(e.message.match(/Not approved/), 'Not approved')
            }
        })

        it('should be able to approve by permit function and successfully do the transfer', async () => {
            const permit = await permitFactory({
                holder: alice,
                spender: bob,
                nonce: 0
            })

            await tokenMinter.permit(permit.holder, permit.spender, permit.nonce, permit.expiry, permit.allowed, permit.signature, { from: bob })
            await tokenMinter.methods[transferFromFour](alice, bob, 1, 5, { from: bob })

            const aliceBalance = await tokenMinter.balanceOf(alice, 1)
            const bobBalance = await tokenMinter.balanceOf(bob, 1)

            assert.equal(aliceBalance, 0, 'Alice balance is wrong')
            assert.equal(bobBalance, 10, 'Bob balance is wrong')
        })
    })
})