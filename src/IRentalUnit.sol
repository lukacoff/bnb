// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {RentalInfo, Season} from "./RentalUnitStructs.sol";

interface IRentalUnit {
    function addSeason(uint256 start, uint256 numberNights) external returns (uint256);

    function setPause(bool state) external;

    function reserve(address customer, uint256 start, uint256 numberNights) external payable;

    function setCurrentSeason(uint256 year) external;

    function updateCapacity(uint256 newCapacity) external;

    function updateCategory(string calldata newCategory) external;

    function updateImagesUrl(string calldata newImagesUrl) external;

    function updateDescriptions(string calldata newDescription) external;

    function updatePricePerNight(uint256 newPricePerNight) external;

    function withdraw() external;

    function checkAvailability(uint256 start, uint256 end) external view returns (bool);

    function getInfo() external view returns (RentalInfo memory);

    function getSetSeasonId() external view returns (uint256);

    function getSeason(uint256 seasonId) external view returns (Season memory);

    function reservationCost(uint256 numberNights) external view returns (uint256);

    function paused() external view returns (bool);
}
