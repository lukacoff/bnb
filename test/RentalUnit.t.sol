// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {RentalUnit} from "../src/RentalUnit.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {Errors} from "../src/libs/Errors.sol";

contract RentalUnitTest is Test {
    RentalUnit public rentalUnit;
    address public owner = makeAddr("owner");
    address public nonOwner = makeAddr("noOwner");

    // Helper: simulate the next midnight after the current block.timestamp
    function getNextMidnight() internal view returns (uint256) {
        // Round up to the next multiple of 1 days
        return ((block.timestamp + 1 days) / 1 days) * 1 days;
    }

    function createValidSeason() internal returns (uint256 seasonId, uint256 start, uint256 end) {
        // For the purpose of the test, we define start as next midnight.
        uint256 nowTime = block.timestamp;
        start = ((nowTime + 1 days) / 1 days) * 1 days;
        uint256 numberNights = 10;
        end = start + numberNights * 1 days;

        // Create season and return its ID.
        vm.prank(owner);
        seasonId = rentalUnit.addSeason(start, numberNights);
    }

    function setUp() public {
        vm.prank(owner);
        rentalUnit =
            new RentalUnit(owner, "Test", "T", "Test", "Test", "Test", "Test", "Test", "http://test.test", 10, 100);
    }

    function test_deploy() public view {
        RentalUnit.RentalInfo memory info = rentalUnit.getInfo();
        console.log(info.country);
    }

    /*//////////////////////////////////////////////////////////////
                           addSeason
    //////////////////////////////////////////////////////////////*/
    function testAddSeasonSuccess() public {
        uint256 start = getNextMidnight();
        uint256 numberNights = 10;

        // Call as owner
        vm.prank(owner);
        uint256 seasonId = rentalUnit.addSeason(start, numberNights);

        // Retrieve season data and verify
        RentalUnit.Season memory s = rentalUnit.getSeason(seasonId);
        assertEq(s.start, start, "Start time mismatch");
        assertEq(s.end, start + numberNights * 1 days, "End time mismatch");
        assertEq(s.numberDays, numberNights, "Number of nights mismatch");
    }

    function testRevertWhenStartInPast() public {
        uint256 pastTime = block.timestamp; // start <= block.timestamp
        uint256 numberNights = 5;

        vm.prank(owner);
        // Expect revert with custom error Errors.StartInPast()
        vm.expectRevert(abi.encodeWithSelector(Errors.StartInPast.selector));
        rentalUnit.addSeason(pastTime, numberNights);
    }

    function testRevertWhenStartNotAtMidnight() public {
        uint256 start = getNextMidnight() + 1; // not aligned with midnight
        uint256 numberNights = 5;

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Errors.StartNotAtMidnight.selector));
        rentalUnit.addSeason(start, numberNights);
    }

    function testRevertWhenNumberNightsIsZero() public {
        uint256 start = getNextMidnight();
        uint256 numberNights = 0;

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidNumberOfNights.selector));
        rentalUnit.addSeason(start, numberNights);
    }

    function testRevertWhenNumberNightsTooHigh() public {
        uint256 start = getNextMidnight();
        uint256 numberNights = 257; // > 256

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidNumberOfNights.selector));
        rentalUnit.addSeason(start, numberNights);
    }

    function testRevertWhenCallerNotOwner() public {
        uint256 start = getNextMidnight();
        uint256 numberNights = 10;

        // Non-owner call should revert (onlyOwner)
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.addSeason(start, numberNights);
    }

    /*//////////////////////////////////////////////////////////////
                           pause
    //////////////////////////////////////////////////////////////*/
    function testSetPauseTrueSuccess() public {
        // Initially, the contract should be unpaused (false).
        bool initial = rentalUnit.paused();
        assertEq(initial, false, "Initial pause state should be false");

        // Expect the Pause event with state = true.
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit RentalUnit.Pause(owner, true);

        // Call pause(true) as owner.
        rentalUnit.setPause(true);

        // Verify that the state is now true.
        bool newState = rentalUnit.paused();
        assertEq(newState, true, "Pause state should be true after pause(true)");
    }

    function testSetPauseTrueAlreadySetReverts() public {
        // First, set pause state to true.
        vm.prank(owner);
        rentalUnit.setPause(true);
        assertEq(rentalUnit.paused(), true, "Pause state should be true");

        // Now, calling pause(true) again should revert.
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Errors.PauseStateUnchanged.selector));
        rentalUnit.setPause(true);
    }

    function testSetPauseFalseSuccess() public {
        // First, set the state to true.
        vm.prank(owner);
        rentalUnit.setPause(true);
        assertEq(rentalUnit.paused(), true, "Pause state should be true");

        // Expect the Pause event with state = false.
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit RentalUnit.Pause(owner, false);

        // Now call pause(false) to unpause.
        rentalUnit.setPause(false);

        // Verify that the state is now false.
        bool newState = rentalUnit.paused();
        assertEq(newState, false, "Pause state should be false after pause(false)");
    }

    function testSetPauseFalseAlreadyUnpausedReverts() public {
        // Contract starts unpaused (false), so calling pause(false) should revert.
        bool initial = rentalUnit.paused();
        assertEq(initial, false, "Initial pause state should be false");

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Errors.PauseStateUnchanged.selector));
        rentalUnit.setPause(false);
    }

    function testNonOwnerCannotCallPause() public {
        // Attempting to call pause (either true or false) as a non-owner should revert.
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.setPause(true);

        // Also test for pause(false)
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.setPause(false);
    }

    /*//////////////////////////////////////////////////////////////
                           setCurrentSeason
    //////////////////////////////////////////////////////////////*/
    function testSetCurrentSeasonSuccess() public {
        // Arrange: create a valid season.
        (uint256 seasonId, uint256 start, uint256 end) = createValidSeason();

        // Expect SeasonSet event with the correct parameters.
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit RentalUnit.SeasonSet(seasonId, start, end);

        // Act: set current season.
        rentalUnit.setCurrentSeason(seasonId);

        // Assert: Verify that current season is updated.
        uint256 current = rentalUnit.getSetSeasonId();
        assertEq(current, seasonId, "Current season not updated");
    }

    function testSetCurrentSeasonRevertsForNonExistentSeason() public {
        // Arrange: use a seasonId that does not exist. We assume season.start == 0 indicates non-existence.
        uint256 invalidSeasonId = 9999; // this id has not been created.

        // Act & Assert: calling setCurrentSeason with an invalid id should revert.
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Errors.SeasonNotExist.selector));
        rentalUnit.setCurrentSeason(invalidSeasonId);
    }

    function testNonOwnerCannotSetCurrentSeason() public {
        // Arrange: Create a valid season first.
        (uint256 seasonId,,) = createValidSeason();

        // Act & Assert: non-owner calling setCurrentSeason should revert.
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.setCurrentSeason(seasonId);
    }
}
