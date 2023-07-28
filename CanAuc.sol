// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    //function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address from, address to, uint nftId) external;
}

contract Auction {
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
    bool public cancelled;

    address payable public highestBidder;
    uint bal= msg.value;
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
        endAt = uint32(block.timestamp) + 3 minutes;
        nft.transferFrom(seller, address(this), nftId);
        emit Start();

    }
   function bid() external payable {

       require(started, "not started");
       require(!cancelled, "Auction was cancelled. You cannot bid");
       require(block.timestamp < endAt, "Auction has ended. You cannot bid now");
       require(msg.value > highestBid, "value should be greater that current highest bid");
       require(msg.sender!= seller, "seller cannot bid");

        if(highestBidder != address(0)) {
        bids[highestBidder] += highestBid;
       }
        highestBid= msg.value;
        highestBidder= payable(msg.sender);
        
        emit Bid(msg.sender, msg.value);
   }

    function withdraw() external {
        require(!cancelled, "Since Auction was cancelled, plz click withdrawAfterCancelAuc to receive back your money");
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    function cancelAuc() public {
        require(msg.sender== seller, "only autioneer can cancel the auction");
        require(started, " You cannot cancel an auction that is not yet started.");
        require(!ended, "Auction was ended. You cannot cancel now");
        require(block.timestamp < endAt, "Auction was ended successfully. You cannot cancel now.");
        cancelled= true;
        nft.transferFrom(address(this), seller, nftId);
        // uint bal = bids[highestBidder];
        // bids[highestBidder] = 0;
        // payable(highestBidder).transfer(bal);
        highestBidder.transfer(highestBid);

    }

    function withdrawAfterCancelAuc() public {

        
        require(cancelled, "Auction wasnt cancelled");
        //require();
        uint bal=bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
        //uint bal1= bids[highestBidder];
        
    }

    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");
        require(!cancelled, "The Auction was cancelled by the auctioneer. Plz select withdrawAfterCancelAuc to receive back your money");

        ended = true;
        if (highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}