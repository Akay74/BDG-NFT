const { ethers } = require('hardhat');

async function main() {
  // Get the contract factory for the BGDNFT contract
  const BGDNFT = await ethers.getContractFactory('BGDNFT');

  // Deploy the contract with the name and symbol arguments
  const bgdnft = await BGDNFT.deploy('BigGreenDildo', 'BGD');

  // Wait for the contract to be deployed
  await bgdnft.deployed();

  // Log the contract address
  console.log('Contract deployed to:', bgdnft.address);
}

main()
 .then(() => process.exit(0))
 .catch((error) => {
    console.error(error);
    process.exit(1);
  });