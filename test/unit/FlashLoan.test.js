const { expect, assert } = require("chai")
const { BigNumber } = require("ethers")
const { ethers, waffle, artifacts } = require("hardhat")
const hre = require("hardhat")

const {
    MATIC_DAI,
    MATIC_DAI_WHALE,
    MATIC_POOL_ADDRESS_PROVIDER,
} = require("../../helper-hardhat-config")

describe("Deploy a Flash Loan", () => {
    it("takes flash loan and return it", async () => {
        const flashLoanExampleFactory = await ethers.getContractFactory("FlashLoan")
        const flashLoan = await flashLoanExampleFactory.deploy(MATIC_POOL_ADDRESS_PROVIDER)
        flashLoan.deployed()

        const DAIToken = await ethers.getContractAt("IERC20", MATIC_DAI)
        const BALANCE_AMOUNT_DAI = ethers.utils.parseEther("2000")

        // Impersonate the MATIC_DAI_WHALE account to be able to send transactions from that account
        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [MATIC_DAI_WHALE],
        })
        const signer = await ethers.getSigner(MATIC_DAI_WHALE)
        // getting 2000 Matic to flashLoan contract from MATIC_DAI_WHALE
        await DAIToken.connect(signer).transfer(flashLoan.address, BALANCE_AMOUNT_DAI)
        // flashLoan contract Borrowing 1000 DAI from Aave
        const tx = await flashLoan.createFlashLoan(MATIC_DAI, 1000)
        await tx.wait(1)
        // Aave contract will call the executeOperation
        // this will repay the borrowed DAI + premium

        // DAI balance of flashLoan contract after repayment of loan
        const remainingBalance = await DAIToken.balanceOf(flashLoan.address)
        // borrowed DAI + premium > borrowed DAI => remainingBalance < earlier balance == 2000 == BALANCE_AMOUNT_DAI
        expect(remainingBalance.lt(BALANCE_AMOUNT_DAI)).to.be.true
    })
})
