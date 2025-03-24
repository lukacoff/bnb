// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RentalUnit} from "../src/RentalUnit.sol";

contract RentalUnitTest is Test {
    RentalUnit public rentalUnit;

    function setUp() public {
        rentalUnit =
            new RentalUnit(msg.sender, "Test", "T", "Test", "Test", "Test", "Test", "Test", "http://test.test", 10, 100);
    }

    function test_deploy() public view {
        RentalUnit.RentalInfo memory info = rentalUnit.getInfo();
        console.log(info.country);
    }
}
