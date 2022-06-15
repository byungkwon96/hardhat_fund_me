const { ethers, getNamedAccounts, network } = require("hardhat")
const { deverlopmentChains } = require("../../helper-hardhat-config")

//skip if its not uploaded to network
deverlopmentChains.includes(network.name)
    ? describe.skip //last step of development journey
    : describe("FundMe", async function () {
          let fundMe
          let deployer
          const sendValue = ethers.utils.parseEther("1")
          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })
      })
