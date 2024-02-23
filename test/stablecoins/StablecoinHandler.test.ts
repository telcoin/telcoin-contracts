import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Stablecoin, AmirX, TestToken } from "../../typechain-types";

describe("StablecoinHandler", () => {
    const MINTER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('MINTER_ROLE'));
    const BURNER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('BURNER_ROLE'));
    const PAUSER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('PAUSER_ROLE'));
    const SWAPPER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('SWAPPER_ROLE'));
    const MAINTAINER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('MAINTAINER_ROLE'));

    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

    let deployer: SignerWithAddress;
    let holder: SignerWithAddress;
    let eUSD: Stablecoin;
    let eMXN: Stablecoin;
    let USDC: TestToken;
    let stablecoinHandler: AmirX;

    beforeEach("setup", async () => {
        [deployer, holder] = await ethers.getSigners();

        const StablecoinHandler_Factory = await ethers.getContractFactory("AmirX", deployer);
        stablecoinHandler = await StablecoinHandler_Factory.deploy();
    });

    describe("Static Values", () => {
        it("PAUSER_ROLE", async () => {
            expect(await stablecoinHandler.PAUSER_ROLE()).to.equal(PAUSER_ROLE);
        });

        it("SWAPPER_ROLE", async () => {
            expect(await stablecoinHandler.SWAPPER_ROLE()).to.equal(SWAPPER_ROLE);
        });

        it("MAINTAINER_ROLE", async () => {
            expect(await stablecoinHandler.MAINTAINER_ROLE()).to.equal(MAINTAINER_ROLE);
        });
    });

    describe("Pausing", () => {
        beforeEach("setup", async () => {
            await stablecoinHandler.initialize();
            await stablecoinHandler.grantRole(PAUSER_ROLE, deployer);
        });

        it("pause", async () => {
            expect(await stablecoinHandler.paused()).to.equal(false);
            await expect(stablecoinHandler.pause()).to.emit(stablecoinHandler, "Paused");
            expect(await stablecoinHandler.paused()).to.equal(true);
        });

        it("unpause", async () => {
            await expect(stablecoinHandler.pause()).to.emit(stablecoinHandler, "Paused");
            expect(await stablecoinHandler.paused()).to.equal(true);
            await expect(stablecoinHandler.unpause()).to.emit(stablecoinHandler, "Unpaused");
            expect(await stablecoinHandler.paused()).to.equal(false);
        });
    });

    describe("Alter supply", () => {
        beforeEach("setup", async () => {
            const Stablecoin_Factory = await ethers.getContractFactory("Stablecoin", deployer);
            eUSD = await Stablecoin_Factory.deploy();
            eMXN = await Stablecoin_Factory.deploy();

            await eUSD.initialize("US Dollar", "eXYZ", 6);
            await eUSD.grantRole(MINTER_ROLE, stablecoinHandler);
            await eUSD.grantRole(BURNER_ROLE, stablecoinHandler);

            await eMXN.initialize("Mexican Peso", "eMXN", 6);
            await eMXN.grantRole(MINTER_ROLE, stablecoinHandler);
            await eMXN.grantRole(BURNER_ROLE, stablecoinHandler);

            await stablecoinHandler.initialize();
            await stablecoinHandler.grantRole(MAINTAINER_ROLE, deployer);
            await stablecoinHandler.grantRole(SWAPPER_ROLE, deployer);
        });

        describe("eXYZ status", () => {
            it("isXYZ", async () => {
                expect(await stablecoinHandler.isXYZ(eUSD)).to.equal(false);
                await expect(stablecoinHandler.UpdateXYZ(eUSD, true, 1000000000, 0)).to.be.not.reverted;
                expect(await stablecoinHandler.isXYZ(eUSD)).to.equal(true);
            });

            it("UpdateXYZ", async () => {
                await expect(stablecoinHandler.UpdateXYZ(eUSD, true, 202, 101)).to.be.not.reverted;
                expect(await stablecoinHandler.getMaxLimit(eUSD)).to.equal(202);
                expect(await stablecoinHandler.getMinLimit(eUSD)).to.equal(101);
            });

            it("ZeroValueInput", async () => {
                const inputs = {
                    destination: ZERO_ADDRESS,
                    origin: ZERO_ADDRESS,
                    oAmount: 0,
                    target: ZERO_ADDRESS,
                    tAmount: 0
                }

                await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.be.revertedWithCustomError(stablecoinHandler, "ZeroValueInput").withArgs("SS");
                inputs.destination = holder.address;
                await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.be.revertedWithCustomError(stablecoinHandler, "ZeroValueInput").withArgs("SS");
                inputs.origin = holder.address;
                await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.be.revertedWithCustomError(stablecoinHandler, "ZeroValueInput").withArgs("SS");
                inputs.oAmount = 1;
                await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.be.revertedWithCustomError(stablecoinHandler, "ZeroValueInput").withArgs("SS");
                inputs.target = holder.address;
                await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.be.revertedWithCustomError(stablecoinHandler, "ZeroValueInput").withArgs("SS");
            });
        });

        describe("swapping", () => {
            beforeEach("setup", async () => {
                await stablecoinHandler.grantRole(SWAPPER_ROLE, deployer);
                await stablecoinHandler.UpdateXYZ(eUSD, true, 1000000000, 0);
                await stablecoinHandler.UpdateXYZ(eMXN, true, 1000000000, 0);

                await eUSD.grantRole(MINTER_ROLE, deployer);

                const Token_Factory = await ethers.getContractFactory("TestToken", deployer);
                USDC = await Token_Factory.deploy("US Dollar Coin", "USDC", 6, holder.address, 10);
            });

            it("swapAndSend", async () => {
                await eUSD.mintTo(holder, 10);
                const inputs = {
                    destination: holder,
                    origin: eUSD,
                    oAmount: 10,
                    target: eMXN,
                    tAmount: 100
                }

                await eUSD.connect(holder).approve(stablecoinHandler, 10);
                await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.not.be.reverted;
                expect(await eUSD.totalSupply()).to.equal(0);
                expect(await eMXN.balanceOf(holder)).to.equal(100);
            });

            it("convertToEXYZ", async () => {
                const inputs = {
                    destination: holder,
                    origin: USDC,
                    oAmount: 10,
                    target: eMXN,
                    tAmount: 100
                }

                await USDC.connect(holder).approve(stablecoinHandler, 10);
                await expect(stablecoinHandler.convertToEXYZ(holder, deployer, inputs)).to.not.be.reverted;
                expect(await USDC.balanceOf(deployer)).to.equal(10);
                expect(await eMXN.balanceOf(holder)).to.equal(100);
            });

            it("convertFromEXYZ", async () => {
                await USDC.mintTo(deployer, 10);
                await USDC.connect(deployer).approve(stablecoinHandler, 10);
                const inputs = {
                    destination: holder,
                    origin: eUSD,
                    oAmount: 10,
                    target: USDC,
                    tAmount: 10
                }

                await eUSD.mintTo(holder, 10);
                await eUSD.connect(holder).approve(stablecoinHandler, 10);

                await expect(stablecoinHandler.convertFromEXYZ(holder, deployer, inputs)).to.not.be.reverted;
                expect(await eUSD.totalSupply()).to.equal(0);
                expect(await USDC.balanceOf(deployer)).to.equal(0);
            });

            describe("Boundry", () => {
                it("Invalid Mint Boundry", async () => {
                    await eUSD.mintTo(holder, 10);
                    const inputs = {
                        destination: holder,
                        origin: eUSD,
                        oAmount: 10,
                        target: eMXN,
                        tAmount: "100000000000000000000"
                    }

                    await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.be.revertedWithCustomError(stablecoinHandler, "InvalidMintBurnBoundry").withArgs(eMXN);
                });

                it("Invalid Burn Boundry", async () => {
                    await eUSD.mintTo(holder, 10);
                    await stablecoinHandler.UpdateXYZ(eUSD, true, 1000000000, 5);
                    const inputs = {
                        destination: holder,
                        origin: eUSD,
                        oAmount: 10,
                        target: eMXN,
                        tAmount: 10
                    }

                    await expect(stablecoinHandler.swapAndSend(holder, inputs)).to.be.revertedWithCustomError(stablecoinHandler, "InvalidMintBurnBoundry").withArgs(eUSD);
                });
            });
        });
    });
});