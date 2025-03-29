// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

struct RentalInfo {
    string title;
    string symbol;
    string country;
    string city;
    string street;
    string description;
    string category;
    string imagesUrl;
    uint256 capacity;
    uint256 pricePerNight;
}

struct Reservation {
    address customer;
    uint256 start;
    uint256 end;
}

struct Season {
    uint256 start;
    uint256 end;
    uint256 numberDays;
}
