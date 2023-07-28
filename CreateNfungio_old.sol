// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CreateNfungio is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    address payable public owner;

    struct NFungioItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        uint8 saletype; ///saletype = 0 -> Not for sale, 1 -> Fixed price sale, 2 -> Auction sale
    }

    mapping(uint256 => NFungioItem) private idNFungioItem;

    event NFungioItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        uint8 saletype
    );

    constructor() ERC721("NFUNGIO", "DTNFO") {}

    function createToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 currentTokenId = _tokenIds.current();

        _mint(msg.sender, currentTokenId);

        _setTokenURI(currentTokenId, tokenURI);

        createNewMarketItem(currentTokenId, price);

        return currentTokenId;
    }

    function createNewMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "price must greater than zero");
        //require(msg.value >= NFungioCommon.listingPrice, "Price must be greater than or equal to listing price");

        idNFungioItem[tokenId] = NFungioItem(
            tokenId,
            payable(msg.sender),
            payable(msg.sender),
            price,
            0
        );
        //payable(address(this)),
        //_transfer(msg.sender, address(this), tokenId);

        emit NFungioItemCreated(tokenId, msg.sender, address(this), price, 0);
    }

    function fetchNFungioMarketItems(uint8 _saleType)
        public
        view
        returns (NFungioItem[] memory)
    {
        uint256 totalTokens = _tokenIds.current();

        uint256 filteredItemCount = 0;

        for (uint256 index = 0; index < totalTokens; index++) {
            uint256 currentId = index + 1;
            if (idNFungioItem[currentId].saletype == _saleType) {
                filteredItemCount += 1;
            }
        }

        uint256 filteredItemIndex = 0;
        NFungioItem[] memory filteredItems = new NFungioItem[](
            filteredItemCount
        );

        for (uint256 index = 0; index < totalTokens; index++) {
            uint256 currentId = index + 1;
            if (idNFungioItem[currentId].saletype == _saleType) {
                NFungioItem storage curentItem = idNFungioItem[currentId];
                filteredItems[filteredItemIndex] = curentItem;
                filteredItemIndex++;
            }
        }
        return filteredItems;
    }

    function fetchOwnedNFungio() public view returns (NFungioItem[] memory) {
        uint256 totalTokens = _tokenIds.current();

        uint256 filteredItemCount = 0;

        for (uint256 index = 0; index < totalTokens; index++) {
            uint256 currentId = index + 1;
            if (
                idNFungioItem[currentId].owner == msg.sender &&
                idNFungioItem[currentId].saletype == 0
            ) {
                filteredItemCount += 1;
            }
        }

        uint256 filteredItemIndex = 0;
        NFungioItem[] memory filteredItems = new NFungioItem[](
            filteredItemCount
        );

        for (uint256 index = 0; index < totalTokens; index++) {
            uint256 currentId = index + 1;
            if (
                idNFungioItem[currentId].owner == msg.sender &&
                idNFungioItem[currentId].saletype == 0
            ) {
                NFungioItem storage curentItem = idNFungioItem[currentId];
                filteredItems[filteredItemIndex] = curentItem;
                filteredItemIndex++;
            }
        }
        return filteredItems;
    }
}
