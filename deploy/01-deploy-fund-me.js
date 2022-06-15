// function deployFunc() {}
// module.exports.defualt = deployFunc
// Same as below (hre) = run time enviornment

const { network } = require("hardhat")
const { verify } = require("../utils/verify")

// module.exports = async (hre) => {
//     const {getNamedAccounts, deployments} = hre
// === (const getNamedAccounts = hre.getNamedAccounts)
// }
// To impore one more
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
// const helperConfig = require("../helper-hardhat-config")
// const networkConfig = helperConfig.networkConfig

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //setting priceFeed Address
    //const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    //if contract doesn't exist

    //if the contract doesn't exist, we deploy a minimal version of for our local testing

    //when going for localhost we want to use mock by forking
    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, // put price Feed Address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }

    log("--------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
