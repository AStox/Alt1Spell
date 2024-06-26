// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Spell, PileLike} from "../src/Spell.sol";

interface RootLike {
    function relyContract(address target, address user) external;
}

contract SpellTest is Test {
    Spell public spell;
    address public root = address(0xF96F18F2c70b57Ec864cC0C8b828450b82Ff63e3);
    address public pile = address(0xE18AAB16cC26EB23740D72875e0C6b52cEbb46b3);
    address public multisig = address(0xf3BceA7494D8f3ac21585CA4b0E52aa175c24C25);

    function setUp() public {
        spell = new Spell();
        vm.prank(multisig);
        RootLike(root).relyContract(pile, address(spell));
    }

    function test_execute() public {
        spell.execute();
        for (uint i = 0; i < 18; i++) {
            uint256 loan = spell.loans(i);
            uint256 debt = PileLike(pile).debt(loan);
            assertEq(debt, 0);
        }
    }

    function test_executingTwice_fails() public {
        spell.execute();
        vm.expectRevert("Already executed");
        spell.execute();
    }
}
