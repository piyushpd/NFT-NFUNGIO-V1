// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


//import "./NFungioLibrary.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CreateNfungio is ERC721URIStorage , ReentrancyGuard {
    using Counters for Counters.Counter;

    //NFungioCommon.NFTokenCounter _tokenIds;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemIds;
     Counters.Counter private _itemsSold;
    address payable public owner;

    struct NFungioItem {
        uint256 itemId;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => NFungioItem) private idNFungioItem;

    event NFungioItemCreated (
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    constructor() ERC721("NFUNGIO", "DTNFO") {
        owner == payable(msg.sender);
    }

    function TestConstract () public pure returns (string memory) {
        return "Hello this is from CreateNFungio Smart Contract";
    }

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256) {
        //NFungioCommon.incrementNFTToken(_tokenIds);
        _tokenIds.increment();

        uint256 currentTokenId = _tokenIds.current(); //NFungioCommon.current(_tokenIds);

        _mint(msg.sender, currentTokenId);

        _setTokenURI(currentTokenId, tokenURI);

        createNewMarketItem(currentTokenId, price);

        return currentTokenId;
    }

    function createNewMarketItem (uint256 tokenId, uint256 price) private {
        require(price > 0, "price must greater than zero");
        //require(msg.value >= NFungioCommon.listingPrice, "Price must be greater than or equal to listing price");
        _itemIds.increment();
    uint256 itemId = _itemIds.current();
        idNFungioItem[tokenId] = NFungioItem (
            itemId,
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);

        emit NFungioItemCreated(itemId,tokenId, msg.sender, address(this), price, false);
    }

    function fetchNFungioMarketItems() public view returns(NFungioItem[] memory)
    {
        uint256 totalTokens = _itemIds.current();

        NFungioItem[] memory items = new NFungioItem[](totalTokens);

        for (uint256 index = 0; index < totalTokens; index++)
        {
            uint256 currentId = index + 1;
            NFungioItem storage curentItem = idNFungioItem[currentId];
            items[index] = curentItem;
        }
        return items;
    }
    function sellItemAndTransferOwnership(uint256 itemId,uint256 listingPrice) public payable nonReentrant{
        uint256 price = idNFungioItem[itemId].price;
        uint256 tokenId = idNFungioItem[itemId].tokenId;
        require(msg.value == price, "Please submit the asking price");
        idNFungioItem[itemId].seller.transfer(msg.value);
        _transfer(msg.sender, address(this), tokenId);
        idNFungioItem[itemId].owner = payable(msg.sender);
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);

    }

}