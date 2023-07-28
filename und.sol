

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

        emit NFungioAuctionStart(nftId, startDateTime, endDateTime);
    }