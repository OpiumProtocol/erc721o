const signature = require('./signature')

const formPermitMessage = ({ permit, minter }) => {
    return {
        types: {
            EIP712Domain: [
                { name: 'name', type: 'string' },
                { name: 'version', type: 'string' },
                { name: 'verifyingContract', type: 'address' },
            ],
            Permit: [
                { name: 'holder', type: 'address' },
                { name: 'spender', type: 'address' },
          
                { name: 'nonce', type: 'uint256' },
                { name: 'expiry', type: 'uint256' },

                { name: 'allowed', type: 'bool' },
            ],
        },
        domain: {
            name: 'ERC721o',
            version: '1',
            verifyingContract: minter.address,
        },
        primaryType: 'Permit',
        message: permit,
    }
}

const permitFactory = async ({
    permit,
    minter
}) => {
    const def = {
        expiry: 0,
        allowed: true
    }

    const resultPermit = {
        ...def,
        ...permit
    }

    resultPermit.signature = await signature.sign(permit.holder, formPermitMessage({ permit: resultPermit, minter }), permit.holder)

    return resultPermit
}

module.exports.permitFactory = permitFactory
