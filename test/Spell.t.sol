// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Spell, PileLike} from "../src/Spell.sol";

interface RootLike {
    function relyContract(address target, address user) external;
}

interface FeedLike {
    function currentNAV() external view returns (uint256);
    function nftValues(bytes32 nftID) external view returns (uint256);
    function nftID(uint loan) external view returns (bytes32);
}

contract SpellTest is Test {
    Spell public spell;
    address public root = address(0xF96F18F2c70b57Ec864cC0C8b828450b82Ff63e3);
    address public pile = address(0xE18AAB16cC26EB23740D72875e0C6b52cEbb46b3);
    address public navFeed = address(0x6fb02533B264d103B84d8f13D11a4865EC96307a);
    address public multisig = address(0xf3BceA7494D8f3ac21585CA4b0E52aa175c24C25);

    function setUp() public {
        spell = new Spell();
        vm.startPrank(multisig);
        RootLike(root).relyContract(pile, address(spell));
        RootLike(root).relyContract(navFeed, address(spell));
        vm.stopPrank();
    }

    // function test_executingTwice_fails() public {
    //     spell.execute();
    //     vm.expectRevert("Already executed");
    //     spell.execute();
    // }

    // function test_navFeed() public {
    //     assertEq(FeedLike(navFeed).currentNAV(), 0);
    // }

    function test_execute() public {
        spell.execute();
        for (uint i = 0; i < 18; i++) {
            uint256 loan = spell.loans(i);
            uint256 debt = PileLike(pile).debt(loan);
            assertEq(debt, 0);
            bytes32 nftID = FeedLike(navFeed).nftID(loan);
            assertEq(FeedLike(navFeed).nftValues(nftID), 0);
        }
        assertEq(FeedLike(navFeed).currentNAV(), 0);
    }

}
