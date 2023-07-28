// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    //function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address from, address to, uint nftId) external;
}

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestBidder, uint amount);
    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;
    uint32 public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;

    constructor(address _nft, uint _nftId, uint _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;

        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external {
      
        require(msg.sender == seller, "not seller");
        require(!started, "started");
        
        started = true;
        endAt = uint32(block.timestamp) + 2 minutes;
        nft.transferFrom(seller, address(this), nftId); //transfering ownership of the nft from seller to this contract
        emit Start();

    }
   function bid() external payable {

       require(started, "not started");
       require(block.timestamp < endAt);
       require(msg.value > highestBid, "value should be greater that current highest bid");

        if(highestBidder != address(0)) {
        bids[highestBidder] += highestBid;
       }
        highestBid= msg.value;
        highestBidder= msg.sender;
        
        emit Bid(msg.sender, msg.value);
   }

    function withdraw() external {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        if (highestBidder != address(0)) {  // address(0) is the one who placed the starting bid
            nft.transferFrom(address(this), highestBidder, nftId);//address(this)=Auction smart contract address
            seller.transfer(highestBid);
        } else {
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}