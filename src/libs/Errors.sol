// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/// @title Errors
/// @notice Library containing custom errors
library Errors {
    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    error InvalidTitle();

    error InvalidSymbol();

    error InvalidCountry();

    error InvalidCity();

    error InvalidStreet();

    error InvalidImagesUrl();

    error InvalidCapacity();

    error InvalidPricePerNight();

    error OverlappingReservation();

    error OutOfSeason();

    error StartInPast();

    error StartNotAtMidnight();

    error EndNotAtMidnight();

    error InvalidNumberOfNights();

    error ReservationPaused();

    error InvalidReservationPeriod();

    error SeasonNotExist();

    error SoulboundTransferNotAllowed();

    error ZeroCustomer();

    error InsufficientPayment();

    error PauseStateUnchanged();
}
