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
    //mapping(uint => address) internal _approvals;

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

    //  function ownerOf(uint id) external view returns (address owner) {
    //     owner = _ownerOf[id];
    //     require(owner != address(0), "token doesn't exist");
    // }

    // function __approve(address spender, uint id) external {
    //     //address owner = _ownerOf[id];
    //     require(
    //         msg.sender == owner, //|| is__approvedForAll[owner][msg.sender],
    //         "not authorized"
    //     );

    //     _approvals[id] = spender;

    //     emit Approval(owner, spender, id);
    // }

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



//////////////////////////////////////////////////
// Smart Contract for Auction


contract Auction {
    event Start();
    event Bid(address indexed sender, uint amount);// nftd id
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestBidder, uint amount);
    IERC721 public nft;
    uint public nftId;
    
    address payable public immutable seller;
    uint32 public endAt;
    uint32 public startAt;
    bool public started;
    bool public ended;
    bool public cancelled;

    address payable public highestBidder;
    uint bal= msg.value;
    uint public highestBid;
    mapping(address => uint) public bids;
    address payable[] public biddersaddress;
    mapping (address => bool) isBidder;
    uint i;
    uint x;

    struct AuctionTracker {
        uint nftId;
        uint32  startAt;
        uint32  endAt;
    }

    mapping(uint => AuctionTracker) public list;

    constructor() {

        seller = payable(msg.sender);
       
    }

    modifier afterDate() {
        require(block.timestamp >= startAt, "Required Date has not been reached");
        _;
    }

    function start(address _nft, uint _nftId, uint _startingBid, uint32 numberMinsStart, uint32 numberHoursStart, 
    uint32 numberDaysStart, uint32 numberMinsEnd, uint32 numberHoursEnd, uint32 numberDaysEnd) external {
      
        require(msg.sender == seller, "not seller");
        require(!started, "Already started");
        
        startAt = uint32(block.timestamp) + (numberMinsStart * 1 minutes) + (numberHoursStart * 1 hours) + (numberDaysStart * 1 days);
        endAt = uint32(block.timestamp) + (numberMinsEnd * 1 minutes) + (numberHoursEnd * 1 hours) + (numberDaysEnd * 1 days);
        
        nft = IERC721(_nft);
        nftId = _nftId;
        highestBid = _startingBid;
        nft.transferFrom(seller, address(this), nftId);
        
        list[nftId]= AuctionTracker(nftId, startAt, endAt);


        emit Start();



    }

    
   function bid(uint nftTokenID) external payable afterDate {

       started = true;
       require(started, "not started");
       require(!cancelled, "Auction was cancelled. You cannot bid");
       require(block.timestamp < endAt, "Auction has ended. You cannot bid now");
       //require(msg.value > highestBid, "value should be greater that current highest bid");
       require(msg.value > highestBid - bids[msg.sender], "value should be greater that current highest bid");
    
       require(msg.sender!= seller, "seller cannot bid");
       require(nftTokenID == nftId, "Wrong tokenID ");
       
       if (isBidder[msg.sender] == false) {

           biddersaddress.push(payable(msg.sender));
           isBidder[msg.sender] = true;
       }
       

       highestBid= msg.value+ bids[msg.sender];

        bids[msg.sender] += msg.value;
       
        highestBidder= payable(msg.sender);

        
        
        emit Bid(msg.sender, msg.value);
   }


    function cancelAuc(uint nftTokenID) public {
        require(msg.sender== seller, "only autioneer can cancel the auction");
        require(started, " You cannot cancel an auction that is not yet started.");
        require(!ended, "Auction was ended. You cannot cancel now");
        require(block.timestamp < endAt, "Auction was ended successfully. You cannot cancel now.");
        require(nftTokenID == nftId, "Wrong tokenID ");
        cancelled= true;
        nft.transferFrom(address(this), seller, nftId);
        // uint bal = bids[highestBidder];
        // bids[highestBidder] = 0;
        // payable(highestBidder).transfer(bal);
        highestBidder.transfer(highestBid);
        bids[highestBidder] = 0;
        for (i=0; i<biddersaddress.length; i++){
           x= bids[biddersaddress[i]];
           payable(biddersaddress[i]).transfer(x);

             
         }

    }

   

    function end(uint nftTokenID) external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");
        require(!cancelled, "The Auction was cancelled by the auctioneer.");
        require(nftTokenID == nftId, "Wrong tokenID ");

        ended = true;
        if (highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
            bids[highestBidder] = 0;
            ////automatic transfer of money
            for (i=0; i<biddersaddress.length; i++){
           x= bids[biddersaddress[i]];//x stores the bids of the bidders one by one,, biddersaddress[i] stores the address
           //transfer to biddersaddress[i], x
           //seller.transfer(highestBid);
           payable(biddersaddress[i]).transfer(x);

             
         }

        } else {
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}





