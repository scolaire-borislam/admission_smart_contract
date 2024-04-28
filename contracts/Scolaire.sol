// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Scolaire is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Strings for uint256;

    function uintToString(uint256 value) public pure returns (string memory) {
        return value.toString();
    }
    
    uint256 private _nextTokenId;
    mapping(uint256 => string) public tokenAppNoMapping;
    constructor(address initialOwner)
        ERC721("Scolaire", "SCOL")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "http://2023-project-public.s3-website-ap-southeast-1.amazonaws.com/nft/";
    }


    event SafeMint(uint256 tokenID, string tokenURI);

    function safeMint(address to, string memory applNo) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        string memory jsonExtension = ".json";
        string memory tempuri= string(abi.encodePacked("SCOL", uintToString(tokenId) , jsonExtension));


        _setTokenURI(tokenId, tempuri);
        tokenAppNoMapping[tokenId] = applNo;

        emit SafeMint(tokenId, tokenURI(tokenId));
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
