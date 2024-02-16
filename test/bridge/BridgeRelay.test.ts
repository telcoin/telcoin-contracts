import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { MockBridgeRelay, TestToken, TestPredicate, TestPOSBridge } from "../../typechain-types";

describe("BridgeRelay", () => {
    const ETHER = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';

    let deployer: SignerWithAddress;
    let holder: SignerWithAddress;
    let telcoin: TestToken;
    let weth: TestToken;
    let matic: TestToken;
    let predicate: TestPredicate;
    let pos: TestPOSBridge;
    let bridgeRelay: MockBridgeRelay;

    beforeEach("setup", async () => {
        [deployer, holder] = await ethers.getSigners();

        const TestToken_Factory = await ethers.getContractFactory("TestToken", deployer);
        telcoin = await TestToken_Factory.deploy("Telcoin", "TEL", 2, deployer.address, 1);
        weth = await TestToken_Factory.deploy("WETH", "WETH", 18, deployer.address, 1);
        matic = await TestToken_Factory.deploy("Test", "TT", 18, deployer.address, 1);

        const TestPredicate_Factory = await ethers.getContractFactory("TestPredicate", deployer);
        predicate = await TestPredicate_Factory.deploy();

        const TestPOSBridge_Factory = await ethers.getContractFactory("TestPOSBridge", deployer);
        pos = await TestPOSBridge_Factory.deploy(predicate.getAddress());

        const BridgeRelay_Factory = await ethers.getContractFactory("MockBridgeRelay", deployer);
        bridgeRelay = await BridgeRelay_Factory.deploy(
            weth.getAddress(),
            matic.getAddress(),
            pos.getAddress(),
            predicate.getAddress(),
            deployer.address
        );
    });

    describe("Static Values", () => {
        it("ETHER_ADDRESS", async () => {
            expect(await bridgeRelay.ETHER()).to.equal(ETHER);
        });

        it("WETH_ADDRESS", async () => {
            expect(await bridgeRelay.WETH()).to.equal(weth);
        });

        it("MATIC_ADDRESS", async () => {
            expect(await bridgeRelay.MATIC()).to.equal(matic);
        });

        it("POS_BRIDGE", async () => {
            expect(await bridgeRelay.POS_BRIDGE()).to.equal(pos);
        });

        it("PREDICATE_ADDRESS", async () => {
            expect(await bridgeRelay.PREDICATE_ADDRESS()).to.equal(predicate);
        });

        it("OWNER_ADDRESS", async () => {
            expect(await bridgeRelay.OWNER_ADDRESS()).to.equal(deployer);
        });
    });

    describe("bridgeTransfer", () => {
        it("MATICUnbridgeable", async () => {
            await matic.transfer(bridgeRelay, 1);
            await expect(bridgeRelay.connect(deployer).bridgeTransfer(matic.getAddress())).to.be.revertedWithCustomError(bridgeRelay, 'MATICUnbridgeable');
            expect(await matic.balanceOf(bridgeRelay)).to.equal(1);
        });

        it("depositEtherFor", async () => {
            await deployer.sendTransaction({ to: bridgeRelay, value: ethers.parseEther("1.0") });
            await expect(bridgeRelay.connect(deployer).bridgeTransfer('0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE')).to.not.be.reverted;
            expect(await ethers.provider.getBalance(bridgeRelay)).to.equal(ethers.parseEther("0"));
            expect(await ethers.provider.getBalance(pos)).to.equal(ethers.parseEther("1.0"));
        });

        it("withdraw and depositEtherFor", async () => {
            await deployer.sendTransaction({ to: weth, value: 1 });
            await weth.transfer(bridgeRelay, 1)
            await expect(bridgeRelay.bridgeTransfer(weth.getAddress())).to.not.be.reverted;
            expect(await weth.balanceOf(bridgeRelay.getAddress())).to.equal(0);
        });

        it("transferERCToBridge", async () => {
            await telcoin.transfer(bridgeRelay, 1)
            await expect(bridgeRelay.bridgeTransfer(telcoin)).to.not.be.reverted;
            expect(await telcoin.balanceOf(bridgeRelay)).to.equal(0);
        });
    });

    describe("Auxiliary", () => {
        beforeEach("setup", async () => {
            await matic.transfer(bridgeRelay, 1);
        });

        it("erc20Rescue", async () => {
            await expect(bridgeRelay.connect(deployer).erc20Rescue(holder)).to.not.be.reverted;
            expect(await matic.balanceOf(holder)).to.equal(1);
            expect(await matic.balanceOf(bridgeRelay)).to.equal(0);
        });

        it("BridgeRelay: caller must be owner", async () => {
            await expect(bridgeRelay.connect(holder).erc20Rescue(holder)).to.be.revertedWith("BridgeRelay: caller must be owner");
            expect(await matic.balanceOf(bridgeRelay)).to.equal(1);
        });
    });
});