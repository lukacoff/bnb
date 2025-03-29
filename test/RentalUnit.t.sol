// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {RentalUnit} from "../src/RentalUnit.sol";
import {ERC721} from "solady/tokens/ERC721.sol";
import {IERC7858} from "../src/ERC7858/IERC7858.sol";
import {RentalInfo, Season} from "../src/RentalUnitStructs.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {Errors} from "../src/libs/Errors.sol";

contract RentalUnitTest is Test {
    RentalUnit public rentalUnit;
    address public owner = makeAddr("owner");
    address public nonOwner = makeAddr("noOwner");
    address public customer = makeAddr("customer");

    // Helper: simulate the next midnight after the current block.timestamp
    function getNextMidnight() internal view returns (uint256) {
        // Round up to the next multiple of 1 days
        return ((block.timestamp + 1 days) / 1 days) * 1 days;
    }

    function createValidSeason(uint256 numberNights) internal returns (uint256 seasonId, uint256 start, uint256 end) {
        // For the purpose of the test, we define start as next midnight.
        uint256 nowTime = block.timestamp;
        start = ((nowTime + 1 days) / 1 days) * 1 days;
        end = start + numberNights * 1 days;

        // Create season and return its ID.
        vm.prank(owner);
        seasonId = rentalUnit.addSeason(start, numberNights);
    }

    function setSeason(uint256 numberNights) internal {
        (uint256 seasonId, uint256 start, uint256 end) = createValidSeason(numberNights);

        vm.prank(owner);
        rentalUnit.setCurrentSeason(seasonId);
    }

    function setUp() public {
        vm.prank(owner);
        rentalUnit = new RentalUnit(
            owner, RentalInfo("Test", "T", "Test", "Test", "Test", "Test", "Test", "http://test.test", 10, 100)
        );

        vm.warp(1735689600);
    }

    function test_deploy() public view {
        RentalInfo memory info = rentalUnit.getInfo();
        console.log(info.country);
    }

    function test_RevertOnEmptyTitle() public {
        RentalInfo memory invalidInfo =
            RentalInfo("", "T", "Test", "Test", "Test", "Test", "Test", "http://test.test", 10, 100);
        vm.expectRevert(Errors.InvalidTitle.selector);
        new RentalUnit(owner, invalidInfo);
    }

    function test_RevertOnEmptySymbol() public {
        RentalInfo memory invalidInfo =
            RentalInfo("Test", "", "Test", "Test", "Test", "Test", "Test", "http://test.test", 10, 100);
        vm.expectRevert(Errors.InvalidSymbol.selector);
        new RentalUnit(owner, invalidInfo);
    }

    function test_RevertOnEmptyCountry() public {
        RentalInfo memory invalidInfo =
            RentalInfo("Test", "T", "", "Test", "Test", "Test", "Test", "http://test.test", 10, 100);
        vm.expectRevert(Errors.InvalidCountry.selector);
        new RentalUnit(owner, invalidInfo);
    }

    function test_RevertOnEmptyCity() public {
        RentalInfo memory invalidInfo =
            RentalInfo("Test", "T", "Test", "", "Test", "Test", "Test", "http://test.test", 10, 100);
        vm.expectRevert(Errors.InvalidCity.selector);
        new RentalUnit(owner, invalidInfo);
    }

    function test_RevertOnEmptyStreet() public {
        RentalInfo memory invalidInfo =
            RentalInfo("Test", "T", "Test", "Test", "", "Test", "Test", "http://test.test", 10, 100);
        vm.expectRevert(Errors.InvalidStreet.selector);
        new RentalUnit(owner, invalidInfo);
    }

    function test_RevertOnEmptyImagesUrl() public {
        RentalInfo memory invalidInfo = RentalInfo("Test", "T", "Test", "Test", "Test", "Test", "Test", "", 10, 100);
        vm.expectRevert(Errors.InvalidImagesUrl.selector);
        new RentalUnit(owner, invalidInfo);
    }

    function test_RevertOnZeroCapacity() public {
        RentalInfo memory invalidInfo =
            RentalInfo("Test", "T", "Test", "Test", "Test", "Test", "Test", "http://test.test", 0, 100);
        vm.expectRevert(Errors.InvalidCapacity.selector);
        new RentalUnit(owner, invalidInfo);
    }

    function test_RevertOnZeroPricePerNight() public {
        RentalInfo memory invalidInfo =
            RentalInfo("Test", "T", "Test", "Test", "Test", "Test", "Test", "http://test.test", 10, 0);
        vm.expectRevert(Errors.InvalidPricePerNight.selector);
        new RentalUnit(owner, invalidInfo);
    }

    /*//////////////////////////////////////////////////////////////
                           addSeason
    //////////////////////////////////////////////////////////////*/
    function testAddSeasonSuccess() public {
        uint256 start = getNextMidnight();
        uint256 numberNights = 100;

        // Call as owner
        vm.prank(owner);
        uint256 seasonId = rentalUnit.addSeason(start, numberNights);

        // Retrieve season data and verify
        Season memory s = rentalUnit.getSeason(seasonId);
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
        (uint256 seasonId, uint256 start, uint256 end) = createValidSeason(100);

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
        (uint256 seasonId,,) = createValidSeason(100);

        // Act & Assert: non-owner calling setCurrentSeason should revert.
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.setCurrentSeason(seasonId);
    }

    /*//////////////////////////////////////////////////////////////
                           updateCapacity
    //////////////////////////////////////////////////////////////*/
    function testUpdateCapacity() public {
        vm.prank(owner);
        rentalUnit.updateCapacity(4);
        // assert the value (assume rentalInfo is public)
        assertEq(rentalUnit.getInfo().capacity, 4);
    }

    function testUpdateCapacityRevertNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.updateCapacity(4);
    }

    function testUpdateCapacityRevertOnZero() public {
        vm.prank(owner);
        vm.expectRevert(Errors.InvalidCapacity.selector);
        rentalUnit.updateCapacity(0);
    }

    /*//////////////////////////////////////////////////////////////
                           updateCategory
    //////////////////////////////////////////////////////////////*/
    function testUpdateCategory() public {
        vm.prank(owner);
        rentalUnit.updateCategory("villa");
        assertEq(rentalUnit.getInfo().category, "villa");
    }

    function testUpdateCategoryRevertNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.updateCategory("villa");
    }

    /*//////////////////////////////////////////////////////////////
                           updateImagesUrl
    //////////////////////////////////////////////////////////////*/

    function testUpdateImagesUrl() public {
        vm.prank(owner);
        rentalUnit.updateImagesUrl("https://example.com");
        assertEq(rentalUnit.getInfo().imagesUrl, "https://example.com");
    }

    function testUpdateImagesUrlRevertEmpty() public {
        vm.prank(owner);
        vm.expectRevert(Errors.InvalidImagesUrl.selector);
        rentalUnit.updateImagesUrl("");
    }

    function testUpdateImagesUrlRevertNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.updateImagesUrl("https://example.com");
    }

    /*//////////////////////////////////////////////////////////////
                           updateDescriptions
    //////////////////////////////////////////////////////////////*/
    function testUpdateDescriptions() public {
        vm.prank(owner);
        rentalUnit.updateDescriptions("Cozy and modern");
        assertEq(rentalUnit.getInfo().description, "Cozy and modern");
    }

    function testUpdateDescriptionsRevertNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.updateDescriptions("Cozy and modern");
    }

    /*//////////////////////////////////////////////////////////////
                           updatePricePerNight
    //////////////////////////////////////////////////////////////*/
    function testUpdatePricePerNight() public {
        vm.prank(owner);
        rentalUnit.updatePricePerNight(100 ether);
        assertEq(rentalUnit.getInfo().pricePerNight, 100 ether);
    }

    function testUpdatePricePerNightRevertZero() public {
        vm.prank(owner);
        vm.expectRevert(Errors.InvalidPricePerNight.selector);
        rentalUnit.updatePricePerNight(0);
    }

    function testUpdatePricePerNightRevertNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(Ownable.Unauthorized.selector);
        rentalUnit.updatePricePerNight(100 ether);
    }

    // /*//////////////////////////////////////////////////////////////
    //                        reserve
    // //////////////////////////////////////////////////////////////*/
    function testReserveSuccess() public {
        setSeason(100);
        uint256 startMidnight = getNextMidnight();
        uint256 numberNights = 10;
        uint256 end = startMidnight + numberNights * 1 days;
        uint256 cost = rentalUnit.reservationCost(numberNights);
        uint256 checkIn = startMidnight - 10 hours;
        uint256 checkOut = end - 13 hours;

        vm.deal(customer, cost);

        assertTrue(rentalUnit.checkAvailability(startMidnight, end));

        vm.prank(customer);
        vm.expectEmit(true, true, true, true);
        emit ERC721.Transfer(address(0), customer, 1);
        vm.expectEmit(true, true, true, true);
        emit IERC7858.TokenExpiryUpdated(1, checkIn, checkOut);
        rentalUnit.reserve{value: cost}(customer, startMidnight, numberNights);

        assertFalse(rentalUnit.checkAvailability(startMidnight, end));
        assertEq(rentalUnit.startTime(1), checkIn);
        assertEq(rentalUnit.endTime(1), checkOut);
    }

    function testReserveMultipleSuccess() public {
        setSeason(100);
        uint256 startMidnight = getNextMidnight();
        uint256 numberNights = 10;
        uint256 end = startMidnight + numberNights * 1 days;
        uint256 cost = rentalUnit.reservationCost(numberNights);
        uint256 checkIn = startMidnight - 10 hours;
        uint256 checkOut = end - 13 hours;

        vm.deal(customer, cost);

        assertTrue(rentalUnit.checkAvailability(startMidnight, end));

        vm.prank(customer);
        vm.expectEmit(true, true, true, true);
        emit ERC721.Transfer(address(0), customer, 1);
        vm.expectEmit(true, true, true, true);
        emit IERC7858.TokenExpiryUpdated(1, checkIn, checkOut);
        rentalUnit.reserve{value: cost}(customer, startMidnight, numberNights);

        assertFalse(rentalUnit.checkAvailability(startMidnight, end));
        assertEq(rentalUnit.startTime(1), checkIn);
        assertEq(rentalUnit.endTime(1), checkOut);

        startMidnight = end;
        end = startMidnight + numberNights * 1 days;
        checkIn = startMidnight - 10 hours;
        checkOut = end - 13 hours;

        vm.deal(customer, cost);

        assertTrue(rentalUnit.checkAvailability(startMidnight, end));

        vm.prank(customer);
        vm.expectEmit(true, true, true, true);
        emit ERC721.Transfer(address(0), customer, 2);
        vm.expectEmit(true, true, true, true);
        emit IERC7858.TokenExpiryUpdated(2, checkIn, checkOut);
        rentalUnit.reserve{value: cost}(customer, startMidnight, numberNights);

        assertFalse(rentalUnit.checkAvailability(startMidnight, end));
        assertEq(rentalUnit.startTime(2), checkIn);
        assertEq(rentalUnit.endTime(2), checkOut);
    }

    function testReserveAllSeasonSuccess() public {
        setSeason(256);
        uint256 startMidnight = getNextMidnight();
        uint256 numberNights = 256;
        uint256 end = startMidnight + numberNights * 1 days;
        uint256 cost = rentalUnit.reservationCost(numberNights);
        uint256 checkIn = startMidnight - 10 hours;
        uint256 checkOut = end - 13 hours;

        vm.deal(customer, cost);

        assertTrue(rentalUnit.checkAvailability(startMidnight, end));

        vm.prank(customer);
        vm.expectEmit(true, true, true, true);
        emit ERC721.Transfer(address(0), customer, 1);
        vm.expectEmit(true, true, true, true);
        emit IERC7858.TokenExpiryUpdated(1, checkIn, checkOut);
        rentalUnit.reserve{value: cost}(customer, startMidnight, numberNights);

        assertFalse(rentalUnit.checkAvailability(startMidnight, end));
        assertEq(rentalUnit.startTime(1), checkIn);
        assertEq(rentalUnit.endTime(1), checkOut);
    }

    function testRevertIfZeroCustomer() public {
        uint256 cost = rentalUnit.reservationCost(10);
        vm.expectRevert(Errors.ZeroCustomer.selector);
        rentalUnit.reserve{value: cost}(address(0), 1 days, 10);
    }

    function testRevertIfStartNotMidnight() public {
        uint256 cost = rentalUnit.reservationCost(10);
        uint256 startMidnight = getNextMidnight() + 1 days;
        uint256 invalidStart = startMidnight + 1; // Not at midnight

        vm.deal(customer, cost);
        vm.prank(customer);
        vm.expectRevert(Errors.StartNotAtMidnight.selector);
        rentalUnit.reserve{value: cost}(customer, invalidStart, 10);
    }

    function testRevertIfInvalidNumberNights() public {
        uint256 cost = rentalUnit.reservationCost(1);
        uint256 startMidnight = getNextMidnight() + 1 days;

        vm.deal(customer, cost);

        vm.prank(customer);
        vm.expectRevert(Errors.InvalidNumberOfNights.selector);
        rentalUnit.reserve{value: cost}(customer, startMidnight, 0);

        vm.expectRevert(Errors.InvalidNumberOfNights.selector);
        rentalUnit.reserve{value: cost}(customer, startMidnight, 257);
    }

    function testRevertIfInsufficientPayment() public {
        setSeason(100);
        uint256 startMidnight = getNextMidnight() + 1 days;
        uint256 numberNights = 10;
        uint256 end = startMidnight + numberNights * 1 days;
        uint256 cost = rentalUnit.reservationCost(numberNights);

        vm.deal(customer, cost - 1);

        vm.prank(customer);
        vm.expectRevert(Errors.InsufficientPayment.selector);
        rentalUnit.reserve{value: cost - 1}(customer, startMidnight, numberNights);
    }

    function testRevertIfOutOfSeason() public {
        setSeason(100);
        uint256 startMidnight = getNextMidnight();
        uint256 numberNights = 10;
        uint256 end = startMidnight + numberNights * 1 days;
        uint256 cost = rentalUnit.reservationCost(numberNights);
        vm.deal(customer, cost);

        uint256 outStart = startMidnight - 1 days;

        vm.prank(customer);
        vm.expectRevert(Errors.OutOfSeason.selector);
        rentalUnit.reserve{value: cost}(customer, outStart, numberNights);

        numberNights = 101;
        end = startMidnight + numberNights * 1 days;
        cost = rentalUnit.reservationCost(numberNights);
        vm.deal(customer, cost);

        vm.prank(customer);
        vm.expectRevert(Errors.OutOfSeason.selector);
        rentalUnit.reserve{value: cost}(customer, startMidnight, numberNights);
    }

    function testRevertIfOverlappingReservation() public {
        setSeason(100);
        uint256 startMidnight = getNextMidnight();
        uint256 numberNights = 10;
        uint256 end = startMidnight + numberNights * 1 days;
        uint256 cost = rentalUnit.reservationCost(numberNights);
        vm.deal(customer, cost * 2);

        assertTrue(rentalUnit.checkAvailability(startMidnight, end));

        // First reservation
        vm.prank(customer);
        rentalUnit.reserve{value: cost}(customer, startMidnight, numberNights);

        startMidnight = getNextMidnight() + 5 days;

        assertFalse(rentalUnit.checkAvailability(startMidnight, startMidnight + numberNights * 1 days));

        // Second reservation overlaps
        vm.prank(customer);
        vm.expectRevert(Errors.OverlappingReservation.selector);
        rentalUnit.reserve{value: cost}(customer, startMidnight, numberNights);
    }
}
