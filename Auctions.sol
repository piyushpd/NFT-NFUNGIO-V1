// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Auction {
    IERC721 public nft;
    address payable public owner;

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

    event NFungioAuctionStart(
        uint256 indexed tokenId,
        uint256 startDate,
        uint256 endDate
    );

    event NFungioBids(
        uint256 indexed tokenId,
        address bidder,
        uint256 bidAmount,
        uint256 timestamp
    );

    constructor() {
        owner = payable(msg.sender);
    }

    modifier bidValidation(
        address nftContract,
        uint256 tokenId,
        uint256 bidAmount
    ) {
        require(
            idNFungioAuction[tokenId].tokenId == tokenId,
            "Not available for Auction"
        );
        require(
            IERC721(nftContract).ownerOf(tokenId) != msg.sender,
            "Owner cannot purchase their own NFungio"
        );
        require(
            block.timestamp >= idNFungioAuction[tokenId].startDate,
            "Auction not yet started"
        );
        require(
            block.timestamp < idNFungioAuction[tokenId].endDate,
            "Auction has ended. You cannot bid now"
        );
        require(
            msg.value > idNFungioAuction[tokenId].startingBid,
            "Bid amount should be greater than the base price"
        );
        _;
    }

    modifier cancelAuctionValidation(address nftContract, uint256 tokenId) {
        require(
            idNFungioAuction[tokenId].tokenId == tokenId,
            "Auction cannot be cancelled"
        );
        require(
            
            IERC721(nftContract).ownerOf(tokenId) == msg.sender,
            "Only owner can cancel the auction"
        );
        require(
            block.timestamp < idNFungioAuction[tokenId].endDate,
            "Auction has ended. You cannot cancel it"
        );
        _;
    }

    modifier endAuctionValidation(address nftContract, uint256 tokenId) {
        require(
            idNFungioAuction[tokenId].tokenId == tokenId,
            "Auction cannot be cancelled"   ///////////////////////////////////////////////////
        );
        // require(
        //     IERC721(nftContract).ownerOf(tokenId) != msg.sender,
        //     "Only owner can cancel the auction"
        // );
        require(
            block.timestamp > idNFungioAuction[tokenId].endDate,
            "Auction has not yet ended."
        );
        _;
    }

    function startAuction(
        uint256 nftId,
        uint256 startingBid,
        uint256 startDateTime,
        uint256 endDateTime
    ) external {
        idNFungioAuction[nftId] = NFungioAuction(
            nftId,
            startDateTime,
            endDateTime,
            startingBid
        );

       

        emit NFungioAuctionStart(nftId, startDateTime, endDateTime);
    }

    function bid(
        address nftContract,
        uint256 tokenId
    ) external payable bidValidation(nftContract, tokenId, msg.value) {
        NFungioBid[] memory sortedBids = sortByBidAmount(idNFungioBid[tokenId]);

        uint256 highestBidValue = sortedBids.length > 0
            ? sortedBids[0].bidAmount
            : idNFungioAuction[tokenId].startingBid;

        require(
            msg.value > highestBidValue,
            "Bidding amount should be greater than the current highest bid value"
        );

        idNFungioBid[tokenId].push(
            NFungioBid(tokenId, msg.sender, msg.value, block.timestamp)
        );

        //console.log(idNFungioBid[tokenId].NFungioBid(msg.sender));
        uint p= idNFungioBid[tokenId];

        emit NFungioBids(tokenId, msg.sender, msg.value, block.timestamp);
    }


    // function print() external {
    // console.log();

    // }


    function endAuction(
        address nftContract,
        uint256 tokenId
    )
        external
        payable
        endAuctionValidation(nftContract, tokenId)
        returns (uint256)
    {
        NFungioBid[] memory sortedBids = sortByBidAmount(idNFungioBid[tokenId]);

        uint256 highestBidAmount;
        for (uint256 bidIndex = 0; bidIndex < sortedBids.length; bidIndex++) {
            console.log(sortedBids[bidIndex].bidder);
            console.log(sortedBids[bidIndex].bidAmount);
            if (bidIndex == 0) {
                address nFungioOwner = IERC721(nftContract).ownerOf(tokenId);
                IERC721(nftContract).safeTransferFrom(
                    address(nFungioOwner),
                    sortedBids[bidIndex].bidder,
                    tokenId
                );

                payable(nFungioOwner).transfer(sortedBids[bidIndex].bidAmount);

                console.log("Above is the highest bidders");  ///////////////////////highest bidder/s
                highestBidAmount = sortedBids[bidIndex].bidAmount;
            } else {
                payable(sortedBids[bidIndex].bidder).transfer(
                    sortedBids[bidIndex].bidAmount
                );
            }
        }

        delete idNFungioBid[tokenId];
        delete idNFungioAuction[tokenId];

        return highestBidAmount;
    }

    function cancelAuction(
        address nftContract,
        uint256 tokenId
    ) external payable cancelAuctionValidation(nftContract, tokenId) {
        for (
            uint256 bidIndex = 0;
            bidIndex < idNFungioBid[tokenId].length;
            bidIndex++
        ) {
            console.log(idNFungioBid[tokenId][bidIndex].bidder);
            console.log(idNFungioBid[tokenId][bidIndex].bidAmount);
            payable(idNFungioBid[tokenId][bidIndex].bidder).transfer(
                idNFungioBid[tokenId][bidIndex].bidAmount
            );
        }

        delete idNFungioBid[tokenId];
        delete idNFungioAuction[tokenId];
    }

    function getCurrentAuctions(
        uint256 tokenId
    ) external view returns (NFungioAuction memory) {
        return idNFungioAuction[tokenId];
    }

    function getBids(
        uint256 tokenId
    ) external view returns (NFungioBid[] memory) {
        return sortByBidAmount(idNFungioBid[tokenId]);
    }

    function getOwner(
        uint256 tokenId,
        address nftContract
    ) public view returns (address) {
        return IERC721(nftContract).ownerOf(tokenId);
    }

    function sortByBidAmount(
        NFungioBid[] memory bidDatas
    ) private pure returns (NFungioBid[] memory) {
        for (uint256 i = 1; i < bidDatas.length; i++)
            for (uint256 j = 0; j < i; j++)
                if (bidDatas[i].bidAmount > bidDatas[j].bidAmount) {
                    NFungioBid memory x = bidDatas[i];
                    bidDatas[i] = bidDatas[j];
                    bidDatas[j] = x;
                }

        return bidDatas;
    }
}