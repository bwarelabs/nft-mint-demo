//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract NftInterface {
    function balanceOf(address owner) external view virtual returns (uint256);
    function mint(address _to, uint256 _tokenId) external virtual;
}

contract Claim is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;

    uint256 public maxCap;
    NftInterface public nftContract;

    constructor() {
    }

    event NftClaimed(address _to, uint256 _tokenId);
    event CapChanged(uint256 _maxCap);

    function setNftContract(address _address) external onlyOwner {
        nftContract = NftInterface(_address);
    }

    function setMaxCap(uint256 _maxCap) external onlyOwner {
        maxCap = _maxCap;
        emit CapChanged(_maxCap);
    }

    function claim() external {
        require(maxCap > _tokenIdCounter.current(), "Max number of NFTs already minted.");
        require(nftContract.balanceOf(msg.sender) == 0, "Only one NFT can be minted for a wallet.");
        _tokenIdCounter.increment();
        nftContract.mint(msg.sender, _tokenIdCounter.current());
        emit NftClaimed(msg.sender, _tokenIdCounter.current());
    }

}