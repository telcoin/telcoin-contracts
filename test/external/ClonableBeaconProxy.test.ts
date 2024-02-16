import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ProxyFactory, MockClonableBeaconProxy, TestWallet } from "../../typechain-types";

describe("ClonableBeaconProxy", () => {
    let deployer: SignerWithAddress;
    let factory: ProxyFactory;
    let implementation: TestWallet;
    let proxy: MockClonableBeaconProxy;

    beforeEach("setup", async () => {
        [deployer] = await ethers.getSigners();

        const ProxyFactory_Factory = await ethers.getContractFactory("ProxyFactory", deployer);
        factory = await ProxyFactory_Factory.deploy();

        const TestWallet_Factory = await ethers.getContractFactory("TestWallet", deployer);
        implementation = await TestWallet_Factory.deploy();

        const ClonableBeaconProxy_Factory = await ethers.getContractFactory("MockClonableBeaconProxy", deployer);
        proxy = await ClonableBeaconProxy_Factory.deploy();

        await factory.initialize(deployer, implementation, proxy);
        await proxy.initialize(factory, '0x');
    });

    describe("internal values", () => {
        it("implementation", async () => {
            expect(await proxy.implementation()).to.equal(implementation);
        });

        it("implementation", async () => {
            expect(await proxy.getBeacon()).to.equal(factory);
        });
    });

    describe("ether", () => {
        it("receive", async () => {
            await deployer.sendTransaction({ to: proxy, value: ethers.parseEther("1.0") });
            expect(await ethers.provider.getBalance(proxy)).to.equal(ethers.parseEther("1.0"));
        });
    });
});