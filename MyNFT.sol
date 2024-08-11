// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 private tokenCount;

    constructor() ERC721("ChupiChain", "CCN") {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return "https://ipfs.io/ipfs/QmeYvzHgq4M58SksnC1pMXmJvoBdtpjjf6Pdw64d6Vh8C1";
    }

    function mintNFT(address to) external {
        tokenCount++;
        _mint(to, tokenCount);
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(msg.sender == ownerOf(tokenId) || getApproved(tokenId) == msg.sender || isApprovedForAll(ownerOf(tokenId), msg.sender), "Caller is not owner nor approved");
        _burn(tokenId);
    }
}