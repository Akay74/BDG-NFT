const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BGDNFT Contract", () => {
  let bGDNFT;
  let deployer;
  let name = "Big Green Dildo";
  let symbol = "BGD";

  beforeEach(async () => {
    const [account] = await ethers.getSigners();
    deployer = account;

    const BGDNFTFactory = await ethers.getContractFactory("BGDNFT");
    bGDNFT = await BGDNFTFactory.deploy(name, symbol);
    await bGDNFT.deployed();
  });

  describe("Deployment", () => {
    it("Should have the correct name and symbol", async () => {
      const contractName = await bGDNFT.name();
      const contractSymbol = await bGDNFT.symbol();

      expect(contractName).to.equal(name);
      expect(contractSymbol).to.equal(symbol);
    });

    it("Should set the deployer as the owner", async () => {
      const owner = await bGDNFT.owner();
      expect(owner).to.equal(deployer.address);
    });

    it("Should start with mintIsActive set to false", async () => {
      const isActive = await bGDNFT.mintIsActive();
      expect(isActive).to.equal(false);
    });
  });

  describe("addTokenURI", () => {
    it("Should revert if called by a non-owner", async () => {
      const [, randomUser] = await ethers.getSigners();

      await expect(bGDNFT.connect(randomUser).addTokenURI("https://example.com/uri1")).to.be.revertedWith(
        "Ownable: caller is not the owner"
      );
    });

    it("Should add a new URI to the mapping", async () => {
      const uri = "https://example.com/uri1";

      const tx = await bGDNFT.addTokenURI(uri);
      await tx.wait();

      const uriId = await bGDNFT.getTotalUris();
      const storedURI = await bGDNFT.getTokenURI(uriId);

      expect(uriId.toNumber()).to.equal(1); // Assuming uriId is a BigNumber
      expect(storedURI).to.equal(uri);
    });
  });

  describe("mint", () => {
    beforeEach(async () => {
      // Add some URIs before tests
      await bGDNFT.addTokenURI("https://example.com/uri1");
      await bGDNFT.addTokenURI("https://example.com/uri2");
    });

    it("Should revert if minting is not active", async () => {
      await expect(bGDNFT.mint()).to.be.revertedWith("Minting is not currently active");
    });

    it("Should revert if the address has already minted", async () => {
      await bGDNFT.toggleMintIsActive(); // Activate minting
      await bGDNFT.mint();
      await expect(bGDNFT.mint()).to.be.reverted();
    });

    it("Should mint a new NFT with a random URI", async () => {
      await bGDNFT.toggleMintIsActive(); // Activate minting

      const tx = await bGDNFT.mint();
      await tx.wait();

      const tokenId = tx.events[0].args.tokenId;
      const owner = await bGDNFT.ownerOf(tokenId);

      expect(owner).to.equal(deployer.address);

      // We cannot guarantee which URI was selected due to randomness
      // But we can check if a URI was indeed set for the minted token
      const tokenURI = await bGDNFT.tokenURI(tokenId);
      expect(tokenURI.length).to.be.greaterThan(0);
    });
  });

  describe('getTokenURI', function () {
    beforeEach(async () => {
      // Add some URIs before tests
      await bGDNFT.addTokenURI("https://example.com/uri1");
      await bGDNFT.addTokenURI("https://example.com/uri2");
    });
    it('should return the correct URI for a valid uid', async function () {
      expect(await bGDNFT.getTokenURI(2)).to.equal("https://example.com/uri2");
    });
  
    it('should revert with an error message for an invalid uid', async function () {
      await expect(bGDNFT.getTokenURI(0)).to.be.revertedWith('Invalid _uriId');
      await expect(bGDNFT.getTokenURI(2)).to.be.revertedWith('Invalid _uriId');
    });
  });
  // Add more tests for other functionalities like batchAddTokenURIs, withdraw, etc.
});
