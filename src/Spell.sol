// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface PileLike {
    function debt(uint256 loan) external view returns (uint256);
    function decDebt(uint256 loan, uint256 amt) external;
    function file(bytes32 what, uint256 rate, uint256 value) external;
    function loanRates(uint256 loan) external view returns (uint256);
    function rates(uint256 loanRate) external view returns (Rate memory);
    function drip(uint256 rate) external;
}

interface FeedLike {
    function calcUpdateNAV() external returns (uint256);
    function update(bytes32 nftID_, uint value, uint risk_) external;
    function nftID(uint loan) external view returns (bytes32);
    function risk(bytes32 nft_) external view returns (uint);
}

struct Rate {
    uint256 pie;
    uint256 chi;
    uint256 ratePerSecond;
     uint48 lastUpdate;
    uint256 fixedRate;
}

contract Spell {
    bool public executed = false;
    uint256[18] public loans = [25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,7,6,5];
    address public alt1Pile = 0xE18AAB16cC26EB23740D72875e0C6b52cEbb46b3;
    address public alt1NavFeed = address(0x6fb02533B264d103B84d8f13D11a4865EC96307a);

    function execute() public {
        require(!executed, "Already executed");
        executed = true;
        cast();
    }

    function cast() private {
        for(uint i = 0; i < loans.length; i++) {
            uint256 loan = loans[i];
            uint256 debt = PileLike(alt1Pile).debt(loan);
            uint256 loanRate = PileLike(alt1Pile).loanRates(loan);
            Rate memory rate = PileLike(alt1Pile).rates(loanRate);
            PileLike(alt1Pile).file("rate", loanRate, rate.ratePerSecond);
            PileLike(alt1Pile).decDebt(loan, debt);
            bytes32 nftID = FeedLike(alt1NavFeed).nftID(loan);
            uint256 risk = FeedLike(alt1NavFeed).risk(nftID);
            risk += 1;
            if (risk > 4) risk = 1;
            FeedLike(alt1NavFeed).update(nftID, 0, risk);
            PileLike(alt1Pile).drip(loanRate);
        }
    }
}
