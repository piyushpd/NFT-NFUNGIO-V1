// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract test {

    address payable public immutable seller;
    uint32 public endAt;
    uint32 public startAt;
    bool public started;
    bool public ended;
    bool public cancelled;
    //uint public b= block.timestamp;
    //bool public isAuctionStarted;

    address payable public highestBidder;
    //uint bal= msg.value;
    uint public highestBid;
    mapping(address => uint) public bids;
    address[] public biddersaddress;
    uint public i;
    uint public x;
     constructor() {

        seller = payable(msg.sender);
       
    }

    struct NFungioAuction {
        uint256 tokenId;
        uint256 startDate;
        uint256 endDate;
        uint256 startingBid;
    }

    mapping(uint256 => NFungioAuction) private idNFungioAuction;

    struct NFungioBid {
        uint256 tokenId;
        address bidder;
        uint256 bidAmount;
        uint256 timestamp;
    }

    mapping(uint256 => NFungioBid[]) private idNFungioBid;

      function startAuction(uint256 nftId,uint256 startingBid,uint256 startDateTime,uint256 endDateTime) external {
        idNFungioAuction[nftId] = NFungioAuction(
            nftId,
            startDateTime,
            endDateTime,
            startingBid
        );
        
        //emit NFungioAuctionStart(nftId, startDateTime, endDateTime);
    }

    function bid() external payable  {

        require(msg.value > highestBid - bids[msg.sender], "value should be greater that current highest bid");
        biddersaddress.push(msg.sender);

        highestBid= msg.value+ bids[msg.sender];

        bids[msg.sender] += msg.value;
        
         // if a bids 40, b bids 50, a has to increase is bid by just 20
         // 20 > 50-40
         // msg.value > highestbid - bids[msg.sender]
         // highestbid = 20+40
         // highestbid = msg.value + bids[msg.sender]

        
        highestBidder= payable(msg.sender);
        //console.log(bids[]);
    }

    function withdraw() external {

        uint bal = bids[msg.sender];
        console.log(bal, "bal");
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
   
    }

}