// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract test1 {

address payable public immutable seller;
 address payable public highestBidder;
    uint bal= msg.value;
    uint public highestBid;
    mapping(address => uint) public bids;
    address payable[] public biddersaddress;
    mapping (address => bool) isBidder;
    uint i;
    uint x;



constructor() {

        seller = payable(msg.sender);
       
    }

 
   function bid() external payable {

       //started = true;
       //require(started, "not started");
       //require(!cancelled, "Auction was cancelled. You cannot bid");
       //require(block.timestamp < endAt, "Auction has ended. You cannot bid now");
       //require(msg.value > highestBid, "value should be greater that current highest bid");
       require(msg.value > highestBid - bids[msg.sender], "value should be greater that current highest bid");
       //require(msg.sender!= seller, "seller cannot bid");
       //require(nftTokenID == nftId, "Wrong tokenID ");
       
       if (isBidder[msg.sender] == false) {

           biddersaddress.push(payable(msg.sender));
           isBidder[msg.sender] = true;
       }
       

       highestBid= msg.value+ bids[msg.sender];

        bids[msg.sender] += msg.value;
       
    //     if(highestBidder != address(0)) {
    //     bids[highestBidder] += highestBid;
        
    //    }
    //     highestBid= msg.value;
        highestBidder= payable(msg.sender);

        
        
        //emit Bid(msg.sender, msg.value);
   }
function printBids() external {
        seller.transfer(highestBid);
        bids[highestBidder] = 0;
        for (i=0; i<biddersaddress.length; i++){
           x= bids[biddersaddress[i]];//x stores the bids of the bidders one by one,, biddersaddress[i] stores the address
           //transfer to biddersaddress[i], x
           console.log("balance of bids", x);
           
           payable(biddersaddress[i]).transfer(x);

             
         }
    }
   function end() external {
        //require(started, "not started");
        //require(block.timestamp >= endAt, "not ended");
        //require(!ended, "ended");
        //require(!cancelled, "The Auction was cancelled by the auctioneer. Plz select withdrawAfterCancelAuc to receive back your money");
        //require(nftTokenID == nftId, "Wrong tokenID ");

        //ended = true;
       // if (highestBidder != address(0)) {
            //nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
            ////automatic transfer of money
            for (i=0; i<biddersaddress.length; i++){
           x= bids[biddersaddress[i]];//x stores the bids of the bidders one by one,, biddersaddress[i] stores the address
           //transfer to biddersaddress[i], x
           //seller.transfer(highestBid);
           payable(biddersaddress[i]).transfer(x);

             
         }

       // } 
    // else {
    //        console.log("this is else"); //nft.transferFrom(address(this), seller, nftId);
    //     }

        //emit End(highestBidder, highestBid);
    }


}