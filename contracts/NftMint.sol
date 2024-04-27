// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BGDNFT is ERC721URIStorage, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;

  // Public variable for mint price in wei
  uint256 public mintPrice = 0.0015 ether;

  // Counter to track minted token IDs
  Counters.Counter private _tokenIdCounter;

  // Mapping to track addresses that have already minted an NFT
  mapping(address => bool) public minted;

  // Mapping to store token URIs associated with their token IDs
  mapping(uint256 => string) private _tokenURIs;

  // Boolean to control if minting is active
  bool public mintIsActive = false;

  // variable to hold the uriIds for the _tokenURIs mapping
  uint256 private _uriId = 0;

  // Event emitted whenever the toggleMintIsActive method is executed
  event EnableMinting();

  // Event emitted when the mint price is changed
  event UpdatedMintPrice(uint256 oldPrice, uint256 newPrice);
  
  // Event emitted whenever the mint function is executed
  event MintedNft(address indexed minter, uint256 tokenId);

  // Event emitted whenever the owner withdraws funds from the contract
  event Withdrawal(address indexed owner, uint256 amount);

  // Custom error to revert if an address has already minted an NFT
  error AddressAlreadyMinted();

  // Custom error to revert if a non-existent token ID is used
  error NonexistentToken(uint256 tokenId);

  /**
   * @dev Constructor for the NFT contract
   * @param name The name of the NFT collection
   * @param symbol The symbol representing the NFT collection
   */
  constructor(string memory name, string memory symbol)
    ERC721(name, symbol)
    Ownable() {}

  /**
   * @notice Function to add a token URI to the mapping, restricted to the contract owner
   * @dev Only callable by the contract owner
   * @param uri The URI (web address) referencing the NFT's metadata
   */
  function addTokenURI(string memory uri) public onlyOwner returns (uint256) {
    _uriId++;
    _tokenURIs[_uriId] = uri;

    return _uriId;
  }

  /**
  * @notice Function to batch add token URIs to the mapping
  * @dev Only callable by the contract owner
  * @param uris An array of URIs to be added to the mapping
  */
  function batchAddTokenURIs(string[] memory uris) public onlyOwner {
      require(uris.length > 0, "No URIs provided");

      for (uint256 i = 0; i < uris.length; i++) {
      _uriId++;
      _tokenURIs[_uriId] = uris[i];
      }
  }

  /**
   * @notice Function to toggle the mintIsActive variable between true and false
   * @dev Only callable by the contract owner
   */
  function toggleMintIsActive() public onlyOwner {
    mintIsActive = !mintIsActive;

    emit EnableMinting();
  }

  /**
   * @notice Function to update the mint price in wei
   * @dev Only callable by the contract owner
   * @param newPrice The new price for minting an NFT in wei
   */
  function updateMintPrice(uint256 newPrice) public onlyOwner {
    uint256 oldPrice = mintPrice;
    mintPrice = newPrice;

    emit UpdatedMintPrice(oldPrice, newPrice);
  }

  /**
   * @notice Function to mint a new NFT with a randomly selected URI
   * @dev Checks for prior mints, generates a random number, selects a URI from the mapping,
   *      and mints the NFT with the associated URI.
   * @return tokenId The tokenId of the newly minted NFT
   */
  function mint() payable public nonReentrant returns (uint256) {
    require(mintIsActive, "Minting is not currently active");
    require(msg.value >= mintPrice, "Insufficient funds sent for mint");
    if (minted[msg.sender]) {
      revert AddressAlreadyMinted();
    }

    _tokenIdCounter.increment();
    uint256 tokenId = _tokenIdCounter.current();

    // Generate a random number to select a token URI
    uint256 randomNumber = _generateRandomNumber();
    string memory selectedURI = _tokenURIs[randomNumber];

    require(bytes(selectedURI).length > 0, "No URI available for token"); // Ensure a URI exists

    minted[msg.sender] = true;
    _safeMint(msg.sender, tokenId);
    _setTokenURI(tokenId, selectedURI);

    emit MintedNft(msg.sender, tokenId);

    return tokenId;
  }

  /**
   * @notice Function to withdraw funds from the contract, restricted to the owner
   * @dev Only callable by the contract owner
   */
  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(address(this).balance);

    emit Withdrawal(msg.sender, balance);
  }

  /**
  * @notice Function to get a token URI by uid
  * @dev Only callable by the contract owner
  * @param uid The unique identifier for the token URI
  * @return string The URI associated with the provided uid
  */
  function getTokenURI(uint256 uid) public view onlyOwner returns (string memory) {
      require(uid > 0 && uid <= _uriId, "Invalid _uriId");
      return _tokenURIs[uid];
  }

  /**
  * @notice Function to get the total number of token uris
  * @dev Only callable by the contract owner
  * @return the total uris stored on-chain
  */
  function getTotalUris() public view onlyOwner returns (uint256) {
    return _uriId;
  }

  /**
   * @dev Internal function to generate a random number between 1 and 1000
   * @return randomNumber A generated random number within the specified range
   */
  function _generateRandomNumber() internal view returns (uint256) {
    // Basic randomness for demonstration, consider a more secure method for production
    uint256 randomValue = uint256(
      keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, msg.sender))
    );

    // Ensure the generated number is within the desired range (1 to 1000, inclusive)
    return (randomValue % _uriId) + 1;
  }

}