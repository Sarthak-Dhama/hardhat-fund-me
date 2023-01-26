const { network } = require("hardhat");
const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  let ethtoUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethtoUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethtoUsdPriceFeedAddress =
      networkConfig[chainId]["ethtoUsdPriceFeedAddress"];
  }

  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: [ethtoUsdPriceFeedAddress],
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(fundMe.address, [ethtoUsdPriceFeedAddress]);
  }
  log("------------------------------------------------------");
};

module.exports.tags = ["all", "fundme"];
