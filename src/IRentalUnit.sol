// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

interface IRentalUnit {
    function checkAvailability(uint256 start, uint256 end) external view returns (bool);

    function reserve(address customer, uint256 start, uint256 numberNights) external payable;

    function setNewSeason(uint256 year, uint256 start, uint256 numberNights) external;

    function setCurrentSeason(uint256 year) external;

    function updateCapacity(uint256 newCapacity) external;

    function updateCategory(string calldata newCategory) external;

    function updateImagesUrl(string calldata newImagesUrl) external;

    function updateDescriptions(string calldata newDescription) external;

    function updatePricePerNight(uint256 newPricePerNight) external;

    function pause() external;

    function unpause() external;
}
