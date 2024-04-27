require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');

require("dotenv").config();
// const { ETHERSCAN_API_URL, PRIVATE_KEY } = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type 
 */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/3ysnLBeWoeUegya5Gich7tRSPcoNkqPh",
      chainId: 11155111,
      accounts: [process.env.PRIVATE_KEY]
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 1,
      accounts: [process.env.PRIVATE_KEY]
    }

  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_URL,
  },

  settings: {
    optimizer: {
      enabled: true,
      runs: 1000
    }
  }
};