import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Stablecoin, MockAmirX, TestToken, TestWallet, TestPlugin, TestAggregator } from "../../typechain-types";

describe("AmirX", () => {
    const MINTER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('MINTER_ROLE'));
    const BURNER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('BURNER_ROLE'));
    const SUPPORT_ROLE = ethers.keccak256(ethers.toUtf8Bytes('SUPPORT_ROLE'));
    const SWAPPER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('SWAPPER_ROLE'));
    const MAINTAINER_ROLE = ethers.keccak256(ethers.toUtf8Bytes('MAINTAINER_ROLE'));

    const TELCOIN_ADDRESS = '0xdF7837DE1F2Fa4631D716CF2502f8b230F1dcc32';
    const MATIC_ADDRESS = '0x0000000000000000000000000000000000001010';
    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

    let deployer: SignerWithAddress;
    let holder: SignerWithAddress;
    let eUSD: Stablecoin;
    let eMXN: Stablecoin;
    let USDC: TestToken;
    let telcoin: TestToken;
    let AmirX: MockAmirX;
    let wallet: TestWallet;
    let plugin: TestPlugin;
    let aggregator: TestAggregator;

    beforeEach("setup", async () => {
        [deployer, holder] = await ethers.getSigners();

        const TestToken_Factory = await ethers.getContractFactory("TestToken", deployer);
        telcoin = await TestToken_Factory.deploy("Telcoin", "Tel", 2, deployer.address, 10);

        const AmirX_Factory = await ethers.getContractFactory("MockAmirX", deployer);
        AmirX = await AmirX_Factory.deploy(telcoin);
    });

    describe("Static Values", () => {
        beforeEach("setup", async () => {
            const AmirX_Factory = await ethers.getContractFactory("MockAmirX", deployer);
            AmirX = await AmirX_Factory.deploy(TELCOIN_ADDRESS);
        });

        it("TELCOIN", async () => {
            expect(await AmirX.TELCOIN()).to.equal(TELCOIN_ADDRESS);
        });

        it("MATIC", async () => {
            expect(await AmirX.MATIC()).to.equal(MATIC_ADDRESS);
        });

        it("SUPPORT_ROLE", async () => {
            expect(await AmirX.SUPPORT_ROLE()).to.equal(SUPPORT_ROLE);
        });
    });

    describe("StablecoinSwap", () => {
        beforeEach("setup", async () => {
            const Stablecoin_Factory = await ethers.getContractFactory("Stablecoin", deployer);
            eUSD = await Stablecoin_Factory.deploy();
            eMXN = await Stablecoin_Factory.deploy();

            await eUSD.initialize("US Dollar", "eXYZ", 6);
            await eUSD.grantRole(MINTER_ROLE, AmirX);
            await eUSD.grantRole(BURNER_ROLE, AmirX);
            await eUSD.grantRole(MINTER_ROLE, deployer);

            await eMXN.initialize("Mexican Peso", "eMXN", 6);
            await eMXN.grantRole(MINTER_ROLE, AmirX);
            await eMXN.grantRole(BURNER_ROLE, AmirX);
            await eMXN.grantRole(MINTER_ROLE, deployer);

            const Token_Factory = await ethers.getContractFactory("TestToken", deployer);
            USDC = await Token_Factory.deploy("US Dollar Coin", "USDC", 6, holder.address, 10);

            await AmirX.initialize();
            await AmirX.grantRole(MAINTAINER_ROLE, deployer);
            await AmirX.grantRole(SWAPPER_ROLE, deployer);
            await AmirX.UpdateXYZ(eUSD, true, 1000000000, 0);
            await AmirX.UpdateXYZ(eMXN, true, 1000000000, 0);
        });

        describe("_verifyStablecoin", () => {
            it("revert with ZeroValueInput(WALLET)", async () => {
                const stableInputs = {
                    destination: ZERO_ADDRESS,
                    origin: ZERO_ADDRESS,
                    oAmount: 0,
                    target: ZERO_ADDRESS,
                    tAmount: 0
                }

                const defiInputs = {
                    aggregator: ZERO_ADDRESS,
                    plugin: ZERO_ADDRESS,
                    feeToken: ZERO_ADDRESS,
                    referrer: ZERO_ADDRESS,
                    referralFee: 0,
                    walletData: '0x',
                    swapData: '0x',
                }

                //wallet == address(0)
                await expect(AmirX.stablecoinSwap(ZERO_ADDRESS, ZERO_ADDRESS, stableInputs, defiInputs)).to.revertedWithCustomError(AmirX, "ZeroValueInput").withArgs("WALLET");
            });

            it("revert with ZeroValueInput(SAFE)", async () => {
                const stableInputs = {
                    destination: ZERO_ADDRESS,
                    origin: ZERO_ADDRESS,
                    oAmount: 0,
                    target: ZERO_ADDRESS,
                    tAmount: 0
                }

                const defiInputs = {
                    aggregator: ZERO_ADDRESS,
                    plugin: ZERO_ADDRESS,
                    feeToken: ZERO_ADDRESS,
                    referrer: ZERO_ADDRESS,
                    referralFee: 0,
                    walletData: '0x',
                    swapData: '0x',
                }

                //safe == address(0)
                //isXYZ(ss.origin)
                await expect(AmirX.stablecoinSwap(deployer, ZERO_ADDRESS, stableInputs, defiInputs)).to.revertedWithCustomError(AmirX, "ZeroValueInput").withArgs("SAFE");
                await AmirX.grantRole(MAINTAINER_ROLE, deployer);
                await expect(AmirX.UpdateXYZ(deployer, true, 1000000000, 0)).to.be.not.reverted;
                stableInputs.origin = await eUSD.getAddress();
                //isXYZ(ss.target)
                await expect(AmirX.stablecoinSwap(deployer, ZERO_ADDRESS, stableInputs, defiInputs)).to.revertedWithCustomError(AmirX, "ZeroValueInput").withArgs("SAFE");
            });
        });

        it("swapAndSend", async () => {
            await eUSD.mintTo(holder, 10);
            const stableInputs = {
                destination: holder,
                origin: eUSD,
                oAmount: 10,
                target: eMXN,
                tAmount: 100
            }

            const defiInputs = {
                aggregator: ZERO_ADDRESS,
                plugin: ZERO_ADDRESS,
                feeToken: ZERO_ADDRESS,
                referrer: ZERO_ADDRESS,
                referralFee: 0,
                walletData: '0x',
                swapData: '0x',
            }

            await eUSD.connect(holder).approve(AmirX, 10);
            await expect(AmirX.stablecoinSwap(holder, ZERO_ADDRESS, stableInputs, defiInputs)).to.not.be.reverted;
            expect(await eUSD.totalSupply()).to.equal(0);
            expect(await eMXN.balanceOf(holder)).to.equal(100);
        });

        it("convertToEXYZ", async () => {
            const stableInputs = {
                destination: holder,
                origin: USDC,
                oAmount: 10,
                target: eMXN,
                tAmount: 100
            }

            const defiInputs = {
                aggregator: ZERO_ADDRESS,
                plugin: ZERO_ADDRESS,
                feeToken: ZERO_ADDRESS,
                referrer: ZERO_ADDRESS,
                referralFee: 0,
                walletData: '0x',
                swapData: '0x',
            }

            await USDC.connect(holder).approve(AmirX, 10);
            await expect(AmirX.stablecoinSwap(holder, deployer, stableInputs, defiInputs)).to.not.be.reverted;
            expect(await USDC.balanceOf(deployer)).to.equal(10);
            expect(await eMXN.balanceOf(holder)).to.equal(100);
        });

        it("convertFromEXYZ", async () => {
            await USDC.mintTo(deployer, 10);
            await USDC.connect(deployer).approve(AmirX, 10);
            const stableInputs = {
                destination: holder,
                origin: eUSD,
                oAmount: 10,
                target: USDC,
                tAmount: 10
            }

            const defiInputs = {
                aggregator: ZERO_ADDRESS,
                plugin: ZERO_ADDRESS,
                feeToken: ZERO_ADDRESS,
                referrer: ZERO_ADDRESS,
                referralFee: 0,
                walletData: '0x',
                swapData: '0x',
            }

            await eUSD.mintTo(holder, 10);
            await eUSD.connect(holder).approve(AmirX, 10);

            await USDC.connect(holder).approve(AmirX, 10);
            await expect(AmirX.stablecoinSwap(holder, deployer, stableInputs, defiInputs)).to.not.be.reverted;
            expect(await eUSD.totalSupply()).to.equal(0);
            expect(await USDC.balanceOf(deployer)).to.equal(0);
        });

        describe("defiSwap", () => {
            beforeEach("setup", async () => {
                const TestWallet_Factory = await ethers.getContractFactory("TestWallet", deployer);
                wallet = await TestWallet_Factory.deploy();

                const TestPlugin_Factory = await ethers.getContractFactory("TestPlugin", deployer);
                plugin = await TestPlugin_Factory.deploy(await telcoin.getAddress());

                const TestAggregator_Factory = await ethers.getContractFactory("TestAggregator", deployer);
                aggregator = await TestAggregator_Factory.deploy(await telcoin.getAddress());
            });

            describe("_verifyDefi", () => {
                it("revert with ZeroValueInput(BUYBACK)", async () => {
                    const stableInputs = {
                        destination: ZERO_ADDRESS,
                        origin: ZERO_ADDRESS,
                        oAmount: 0,
                        target: ZERO_ADDRESS,
                        tAmount: 0
                    }

                    const defiInputs = {
                        aggregator: ZERO_ADDRESS,
                        plugin: ZERO_ADDRESS,
                        feeToken: deployer.address,
                        referrer: ZERO_ADDRESS,
                        referralFee: 0,
                        walletData: await wallet.getTestSelector(),
                        swapData: '0x',
                    }

                    //defi.aggregator == address(0)
                    await expect(AmirX.stablecoinSwap(wallet, holder, stableInputs, defiInputs)).to.revertedWithCustomError(AmirX, "ZeroValueInput").withArgs("BUYBACK");
                    defiInputs.aggregator = deployer.address;
                    //defi.swapData.length == 0
                    await expect(AmirX.stablecoinSwap(wallet, holder, stableInputs, defiInputs)).to.revertedWithCustomError(AmirX, "ZeroValueInput").withArgs("BUYBACK");
                    defiInputs.swapData = deployer.address;
                });

                it("revert with ZeroValueInput(PLUGIN)", async () => {
                    const stableInputs = {
                        destination: ZERO_ADDRESS,
                        origin: ZERO_ADDRESS,
                        oAmount: 0,
                        target: ZERO_ADDRESS,
                        tAmount: 0
                    }

                    const defiInputs = {
                        aggregator: deployer.address,
                        plugin: ZERO_ADDRESS,
                        feeToken: await telcoin.getAddress(),
                        referrer: deployer.address,
                        referralFee: 0,
                        walletData: await wallet.getTestSelector(),
                        swapData: await wallet.getTestSelector(),
                    }

                    //if (defi.feeToken == TELCOIN)
                    //defi.referrer == address(0)
                    await expect(AmirX.stablecoinSwap(wallet, holder, stableInputs, defiInputs)).to.revertedWithCustomError(AmirX, "ZeroValueInput").withArgs("PLUGIN");
                });
            });

            it("wallet call", async () => {
                const stableInputs = {
                    destination: ZERO_ADDRESS,
                    origin: USDC,
                    oAmount: 0,
                    target: ZERO_ADDRESS,
                    tAmount: 0
                }

                const defiInputs = {
                    aggregator: ZERO_ADDRESS,
                    plugin: ZERO_ADDRESS,
                    feeToken: await telcoin.getAddress(),
                    referrer: ZERO_ADDRESS,
                    referralFee: 0,
                    walletData: await wallet.getTestSelector(),
                    swapData: '0x',
                }

                await telcoin.approve(AmirX, 10);
                await expect(AmirX.stablecoinSwap(holder, deployer, stableInputs, defiInputs)).to.not.be.reverted;
                expect(await telcoin.balanceOf(deployer)).to.equal(1000);
            });

            it("_feeDispersal", async () => {
                const stableInputs = {
                    destination: ZERO_ADDRESS,
                    origin: USDC,
                    oAmount: 0,
                    target: ZERO_ADDRESS,
                    tAmount: 0
                }

                const defiInputs = {
                    aggregator: ZERO_ADDRESS,
                    plugin: plugin,
                    feeToken: await telcoin.getAddress(),
                    referrer: deployer,
                    referralFee: 10,
                    walletData: await wallet.getTestSelector(),
                    swapData: '0x',
                }

                await telcoin.approve(AmirX, 10);
                await expect(AmirX.stablecoinSwap(holder, deployer, stableInputs, defiInputs)).to.not.be.reverted;
                expect(await telcoin.balanceOf(plugin)).to.equal(10);
            });

            it("_buyBack with MATIC", async () => {
                const stableInputs = {
                    destination: ZERO_ADDRESS,
                    origin: USDC,
                    oAmount: 0,
                    target: ZERO_ADDRESS,
                    tAmount: 0
                }

                const defiInputs = {
                    aggregator: aggregator,
                    plugin: plugin,
                    feeToken: MATIC_ADDRESS,
                    referrer: ZERO_ADDRESS,
                    referralFee: 0,
                    walletData: await wallet.getTestSelector(),
                    swapData: await aggregator.getMATICSwapSelector(),
                }

                await telcoin.transfer(aggregator, 10);
                await expect(AmirX.stablecoinSwap(holder, deployer, stableInputs, defiInputs)).to.not.be.reverted;
                expect(await telcoin.balanceOf(deployer)).to.equal(1000);
            });

            it("_buyBack wtih ERC20", async () => {
                const stableInputs = {
                    destination: ZERO_ADDRESS,
                    origin: USDC,
                    oAmount: 0,
                    target: ZERO_ADDRESS,
                    tAmount: 0
                }

                const defiInputs = {
                    aggregator: aggregator,
                    plugin: plugin,
                    feeToken: USDC,
                    referrer: ZERO_ADDRESS,
                    referralFee: 0,
                    walletData: await wallet.getTestSelector(),
                    swapData: await aggregator.getSwapSelector(),
                }

                await telcoin.transfer(aggregator, 10);
                await expect(AmirX.stablecoinSwap(holder, deployer, stableInputs, defiInputs)).to.not.be.reverted;
                expect(await telcoin.balanceOf(deployer)).to.equal(1000);
            });
        });
    });

    describe("rescueCrypto", () => {
        beforeEach("setup", async () => {
            const AmirX_Factory = await ethers.getContractFactory("MockAmirX", deployer);
            AmirX = await AmirX_Factory.deploy(TELCOIN_ADDRESS);
            await AmirX.initialize();
            await AmirX.grantRole(SUPPORT_ROLE, deployer);
        });

        it("MATIC insufficient balance", async () => {
            await expect(AmirX.rescueCrypto(MATIC_ADDRESS, 101)).to.be.revertedWith("AmirX: MATIC send failed");
        });

        it("MATIC", async () => {
            deployer.sendTransaction({ value: 101, to: await AmirX.getAddress() });
            await expect(AmirX.rescueCrypto(MATIC_ADDRESS, 101)).to.not.be.reverted;
        });

        it("ERC20", async () => {
            await telcoin.transfer(AmirX, 101);
            await expect(AmirX.rescueCrypto(await telcoin.getAddress(), 101)).to.not.be.reverted;
            expect(await telcoin.balanceOf(deployer)).to.equal(1000);
        });
    });
});