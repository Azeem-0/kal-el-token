const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("KalElToken", function () {
    let Token;
    let KalElToken;
    let owner;
    let user;

    beforeEach(async function () {
        [owner, user] = await ethers.getSigners();

        Token = await ethers.getContractFactory("KalElToken");
        KalElToken = await Token.deploy(
            100,
            "KalElToken",
            "KET",
            1000,
            0
        );
    });

    describe("Deployment", function () {
        it("Should have the correct decimals", async function () {
            expect(await KalElToken.getDecimals()).to.equal(0);
        });

        it("Should deploy the contract with the correct owner", async function () {
            expect(await KalElToken.owner()).to.equal(owner.address);
        });

        it("Should have the correct token name and symbol", async function () {
            expect(await KalElToken.name()).to.equal("KalElToken");
            expect(await KalElToken.symbol()).to.equal("KET");
        });

        it("Should assign the initial supply to the owner", async function () {
            const balance = await KalElToken.balanceOf(owner.address);
            expect(balance).to.equal(100);
        });
    });

    describe("Token operations", function () {
        it("Should allow to transfer tokens", async function () {
            await KalElToken.transfer(user.address, 100);
            const balance = await KalElToken.balanceOf(user.address);
            expect(balance).to.equal(100);
        })

        it("Should allow to approve an allowance", async function () {
            await KalElToken.connect(owner).approve(user.address, 100);
            const allowance = await KalElToken.allowance(owner.address, user.address);;
            expect(allowance).to.equal(100);
        });


        it("Should allow the spender to transfer tokens using transferFrom", async function () {
            await KalElToken.connect(owner).approve(user.address, 200);
            await KalElToken.connect(user).transferFrom(owner.address, user.address, 100);
            const balance = await KalElToken.balanceOf(user.address);
            expect(balance).to.equal(100);
        });

        it("Should fail when transfer amount exceeds balance", async function () {
            await expect(
                KalElToken.connect(owner).transfer(user.address, 1000000)
            ).to.be.revertedWith("KalEl: Insufficient balance to complete the transaction.");
        });
    });

    describe("Minting and Burning", function () {
        it("Should allow minting tokens", async function () {
            await KalElToken.connect(owner).mint(user.address, 500);
            const balance = await KalElToken.balanceOf(user.address);
            expect(balance).to.equal(500);
        });

        it("Should fail minting if it exceeds capped supply", async function () {
            await expect(
                KalElToken.connect(owner).mint(user.address, 100000)
            ).to.be.revertedWith("KalEl: Minting failed. Capped supply limit exceeded.");
        });

        it("Should allow burning tokens", async function () {
            await KalElToken.connect(owner).transfer(user.address, 100);
            await KalElToken.connect(owner).burn(user.address, 50);
            const balance = await KalElToken.balanceOf(user.address);
            expect(balance).to.equal(50);
        });

        it("Should fail burning more tokens than balance", async function () {
            await expect(
                KalElToken.connect(owner).burn(user.address, 200)
            ).to.be.revertedWith("KalEl: Insufficient balance to complete the transaction.");
        });
    });

    describe("Pause/Unpause", function () {
        it("Should allow the owner to pause the contract", async function () {
            await KalElToken.pause();
            expect(await KalElToken.paused()).to.equal(true);
        });

        it("Should allow the owner to unpause the contract", async function () {
            await KalElToken.pause();
            await KalElToken.unpause();
            expect(await KalElToken.paused()).to.equal(false);
        });

        it("Should prevent transfers when paused", async function () {
            await KalElToken.connect(owner).pause();
            await expect(
                KalElToken.connect(owner).transfer(user.address, 100)
            ).to.be.revertedWith("KalEl: Token operations are paused.");
        });

        it("Should allow transfers when unpaused", async function () {
            await KalElToken.pause();
            await KalElToken.unpause();
            await KalElToken.connect(owner).transfer(user.address, 100);
            const balance = await KalElToken.balanceOf(user.address);
            expect(balance).to.equal(100);
        });
    });

    describe("Ownership", function () {
        it("Should allow the owner to transfer ownership", async function () {
            await KalElToken.connect(owner).transferOwnership(user.address);
            expect(await KalElToken.owner()).to.equal(user.address);
        });
    });
});
