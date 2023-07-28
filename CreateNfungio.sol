// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./Auctions.sol";

contract CreateNfungio is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    address payable public owner;

    uint256 listingPrice = 0.0010 ether;

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

    event NFungioSale(
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price,
        uint8 saletype,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only NFungio Market Place owner can change the listing price"
        );
        _;
    }

    constructor() ERC721("NFUNGIO", "DTNFO") {
        owner = payable(msg.sender);
    }

    function updateListingPrice(
        uint256 _listingPrice
    ) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createToken(
        string memory tokenURI,
        uint256 price
    ) public payable returns (uint256) {
        _tokenIds.increment();

        uint256 currentTokenId = _tokenIds.current();

        _mint(msg.sender, currentTokenId);

        _setTokenURI(currentTokenId, tokenURI);

        createNewMarketItem(currentTokenId, price);

        return currentTokenId;
    }

    function fetchNFungioMarketItems()
        public
        view
        returns (NFungioItem[] memory)
    {
        uint256 totalTokens = _tokenIds.current();

        uint256 filteredItemCount = 0;

        for (uint256 index = 0; index < totalTokens; index++) {
            uint256 currentId = index + 1;
            if (idNFungioItem[currentId].saletype != 0) {
                filteredItemCount += 1;
            }
        }

        uint256 filteredItemIndex = 0;
        NFungioItem[] memory filteredItems = new NFungioItem[](
            filteredItemCount
        );

        for (uint256 index = 0; index < totalTokens; index++) {
            uint256 currentId = index + 1;
            if (idNFungioItem[currentId].saletype != 0) {
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
            if (idNFungioItem[currentId].owner == msg.sender) {
                filteredItemCount += 1;
            }
        }

        uint256 filteredItemIndex = 0;
        NFungioItem[] memory filteredItems = new NFungioItem[](
            filteredItemCount
        );

        for (uint256 index = 0; index < totalTokens; index++) {
            uint256 currentId = index + 1;
            if (idNFungioItem[currentId].owner == msg.sender) {
                NFungioItem storage curentItem = idNFungioItem[currentId];
                filteredItems[filteredItemIndex] = curentItem;
                filteredItemIndex++;
            }
        }
        return filteredItems;
    }

    function listNFungioForFixedPriceSale(
        uint256 tokenId,
        uint256 sellingPrice,
        uint8 saleType
    ) public payable {
        require(
            msg.sender == ownerOf(tokenId),
            "Only owner can list it for sale"
        );

        require(
            sellingPrice >= listingPrice,
            "Price should be greater than or equal to listing pricing"
        );

        require((saleType == 1 || saleType == 2), "sale type is incorrect");

        console.log(address(this));

        approve(address(this), tokenId);

        idNFungioItem[tokenId].saletype = saleType;

        idNFungioItem[tokenId].price = sellingPrice;
    }

    function withdrawListing(
        Auction callAuction,
        uint256 tokenId,
        uint256 previousPrice
    ) public payable {
        require(
            msg.sender == ownerOf(tokenId),
            "Only owner can withdraw from sale"
        );

        if (idNFungioItem[tokenId].saletype == 2) {
            callAuction.cancelAuction(address(this), tokenId);
        }

        approve(address(0), tokenId);

        idNFungioItem[tokenId].saletype = 0;

        //If resale will take the price from history
        idNFungioItem[tokenId].price = previousPrice;
    }

    function listNFungioForAuctionSale(
        Auction callAuction,
        uint256 tokenId,
        uint256 startingBid,
        uint256 startDate,
        uint256 endDate
    ) public payable {
        require(
            msg.sender == ownerOf(tokenId),
            "Only owner can list it for sale"
        );

        require(
            startingBid >= listingPrice,
            "Price should be greater than or equal to listing pricing"
        );

        require(
            endDate > startDate,
            "Auction end date should greater than start date"
        );

        console.log(address(callAuction));

        approve(address(callAuction), tokenId);

        callAuction.startAuction(tokenId, startingBid, startDate, endDate);

        idNFungioItem[tokenId].saletype = 2;

        idNFungioItem[tokenId].price = startingBid;
    }

    function buyFixedPriceNFungio(uint256 tokenId) public payable {
        require(
            msg.sender.balance > idNFungioItem[tokenId].price,
            "Insufficient balance"
        );

        require(idNFungioItem[tokenId].saletype == 1, "Not available for sale");

        require(
            msg.sender != idNFungioItem[tokenId].owner,
            "Owner cannot purchase their own NFungio"
        );

        require(
            msg.value == idNFungioItem[tokenId].price,
            "Submit the exact selling price"
        );

        address nFungioOwner = ownerOf(tokenId);

        IERC721(address(this)).safeTransferFrom(
            address(nFungioOwner),
            msg.sender,
            tokenId
        );

        ///payable(owner).transfer(listingPrice);

        ///payable(owner).call{value: listingPrice}(""); - For Reference

        payable(nFungioOwner).transfer(msg.value);

        idNFungioItem[tokenId].owner = payable(msg.sender);

        idNFungioItem[tokenId].price = msg.value;

        idNFungioItem[tokenId].saletype = 0;

        /// Trigger sale event
        emit NFungioSale(
            tokenId,
            nFungioOwner,
            msg.sender,
            msg.value,
            1,
            block.timestamp
        );
    }

    function completeNFungioAuction(
        Auction callAuction,
        uint256 tokenId
    ) public payable {
        require(
            idNFungioItem[tokenId].saletype == 2,
            "Not available for auction"
        );

        // require(
        //     msg.sender != idNFungioItem[tokenId].owner,
        //     "Owner cannot purchase their own NFungio"
        // );

        uint256 highestBidAmount = callAuction.endAuction(
            address(this),
            tokenId
        );

        address nFungioOwner = ownerOf(tokenId);

        idNFungioItem[tokenId].owner = payable(nFungioOwner);

        idNFungioItem[tokenId].price = highestBidAmount;

        idNFungioItem[tokenId].saletype = 0;

        /// Trigger sale event
        emit NFungioSale(
            tokenId,
            idNFungioItem[tokenId].seller,
            nFungioOwner,
            highestBidAmount,
            2,
            block.timestamp
        );
    }

    function createNewMarketItem(uint256 tokenId, uint256 price) private {
        idNFungioItem[tokenId] = NFungioItem(
            tokenId,
            payable(msg.sender),
            payable(msg.sender),
            price,
            0
        );
        //payable(address(this)),
        //_transfer(msg.sender, address(this), tokenId);

        emit NFungioItemCreated(tokenId, msg.sender, msg.sender, price, 0);
    }
}
