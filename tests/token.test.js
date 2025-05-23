
const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('MASOLToken', () => {
    let token, owner, user1;

    beforeEach(async () => {
        [owner, user1] = await ethers.getSigners();
        const MASOLToken = await ethers.getContractFactory('MASOLToken');
        token = await MASOLToken.deploy();
    });

    it('Should airdrop 50 MSL on registration', async () => {
        await token.register(owner.address);
        expect(await token.balanceOf(user1.address)).to.equal(50 * 10**18);
    });

    it('Should reward 5% to upline (6 levels)', async () => {
        await token.register(owner.address); // user1's upline = owner
        expect(await token.balanceOf(owner.address)).to.equal(10_000_000 * 10**18 - 50 * 10**18 + (50 * 0.05 * 10**18));
    });
});
