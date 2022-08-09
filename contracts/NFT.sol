//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721, Ownable, AccessControl {
    using Strings for uint256;

    string public baseURI;
    bool private lockedUrl = false;

    bytes32 public MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public BURNER_ROLE = keccak256("BURNER_ROLE");

    event LockedURL();
    event BaseURIChanged(string _newUri);

    constructor() ERC721("ClaimableToken", "!#$%*") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address _to, uint256 _tokenId) external onlyRole(MINTER_ROLE) {
        _mint(_to, _tokenId);
    }

    function burn(uint256 _tokenId) external onlyRole(BURNER_ROLE) {
        _burn(_tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function updateLockedUrl() external onlyOwner {
        lockedUrl = true;
        emit LockedURL();
    }

    function getLockedUrl() internal view returns (bool) {
        return lockedUrl;
    }

    function setBaseURI(string calldata _newBaseUri) external onlyOwner {
        require(lockedUrl == false, "Can not change Base URI");

        baseURI = _newBaseUri;
        emit BaseURIChanged(_newBaseUri);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        string memory cachedBaseURI = _baseURI();
        return bytes(cachedBaseURI).length > 0 ? 
            string(abi.encodePacked(cachedBaseURI, Strings.toString(tokenId), ".json")) : "";
    }

}
