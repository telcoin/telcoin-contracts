import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ProxyFactory, ClonableBeaconProxy, TestWallet } from "../../typechain-types";

describe("ProxyFactory", () => {
    const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
    const SALT = ethers.keccak256(ethers.toUtf8Bytes('SALT'));
    const DEPLOYER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('DEPLOYER_ROLE'));
    const SUPPORT_ROLE = ethers.keccak256(ethers.toUtf8Bytes('SUPPORT_ROLE'));

    let deployer: SignerWithAddress;
    let factory: ProxyFactory;
    let implementation: TestWallet;
    let proxy: ClonableBeaconProxy;

    beforeEach("setup", async () => {
        [deployer] = await ethers.getSigners();

        const ProxyFactory_Factory = await ethers.getContractFactory("ProxyFactory", deployer);
        factory = await ProxyFactory_Factory.deploy();

        const TestWallet_Factory = await ethers.getContractFactory("TestWallet", deployer);
        implementation = await TestWallet_Factory.deploy();

        const ClonableBeaconProxy_Factory = await ethers.getContractFactory("ClonableBeaconProxy", deployer);
        proxy = await ClonableBeaconProxy_Factory.deploy();

        await factory.initialize(deployer, implementation, proxy);
    });

    describe("Static Values", () => {
        it("DEPLOYER_ROLE", async () => {
            expect(await factory.DEPLOYER_ROLE()).to.equal(DEPLOYER_ROLE);
        });

        it("SUPPORT_ROLE", async () => {
            expect(await factory.SUPPORT_ROLE()).to.equal(SUPPORT_ROLE);
        });
    });

    describe("Init Values", () => {
        it("implementation", async () => {
            expect(await factory.implementation()).to.equal(implementation);
        });

        it("proxy", async () => {
            expect(await factory.proxy()).to.equal(proxy);
        });
    });

    describe("Update Values", () => {
        beforeEach("setup", async () => {
            await factory.grantRole(SUPPORT_ROLE, deployer);
        });

        it("ImplementationUpdated", async () => {
            const TestWallet_Factory = await ethers.getContractFactory("TestWallet", deployer);
            let newImplementation = await TestWallet_Factory.deploy();
            await expect(factory.upgradeTo(newImplementation)).to.not.be.reverted;
            expect(await factory.implementation()).to.equal(newImplementation);
        });

        it("ProxyUpdated", async () => {
            const ProxyFactory_Factory = await ethers.getContractFactory("ProxyFactory", deployer);
            let newProxy = await ProxyFactory_Factory.deploy();
            await expect(factory.setProxy(newProxy)).to.not.be.reverted;
            expect(await factory.proxy()).to.equal(newProxy);
        });

        it("InvalidImplementation", async () => {
            await expect(factory.upgradeTo(ZERO_ADDRESS)).to.be.revertedWithCustomError(factory, 'InvalidImplementation').withArgs(ZERO_ADDRESS);
        });

        it("InvalidProxy", async () => {
            await expect(factory.setProxy(ZERO_ADDRESS)).to.be.revertedWithCustomError(factory, 'InvalidProxy').withArgs(ZERO_ADDRESS);
        });
    });

    describe("Create", () => {
        beforeEach("setup", async () => {
            await factory.grantRole(DEPLOYER_ROLE, deployer);
        });

        it("Deployed", async () => {
            await expect(factory.create([SALT], ['0x'])).to.emit(factory, 'Deployed');
        });

        it("ProxyFactory: array length mismatch", async () => {
            await expect(factory.create([SALT], ['0x', '0x'])).to.be.revertedWith('ProxyFactory: array length mismatch');
        });
    });
});