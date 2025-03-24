// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC7858} from "./ERC7858/IERC7858.sol";
import {IRentalUnit} from "./IRentalUnit.sol";

contract RentalUnit is IRentalUnit, ERC721Pausable, IERC7858, Ownable {
    struct RentalInfo {
        string title;
        string country;
        string city;
        string street;
        string description;
        string category;
        string imagesURL;
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

    RentalInfo public rentalInfo;
    mapping(uint256 year => Season season) public seasons;
    mapping(uint256 year => uint256 calendar) private _bitCalendars;
    mapping(uint256 tokenId => Reservation reservation) private _reservations;
    uint256 private _tokenIdCounter;
    uint256 currentSeason;

    constructor(
        address owner_,
        string memory title_,
        string memory symbol_,
        string memory country_,
        string memory city_,
        string memory street_,
        string memory description_,
        string memory category_,
        string memory imagesUrl_,
        uint256 capacity_,
        uint256 pricePerNight_
    ) ERC721(title_, symbol_) Ownable(owner_) {
        require(bytes(title_).length > 0, "Invalid title");
        require(bytes(symbol_).length > 0, "Invalid symbol");
        require(bytes(country_).length > 2, "Invalid country");
        require(bytes(city_).length > 0, "Invalid city");
        require(bytes(street_).length > 0, "Invalid street address");
        require(bytes(imagesUrl_).length > 0, "Invalid images URL");
        require(capacity_ > 0, "Invalid capacity");
        require(pricePerNight_ > 0, "Invalid price per night");

        rentalInfo.title = title_;
        rentalInfo.country = country_;
        rentalInfo.city = city_;
        rentalInfo.street = street_;
        rentalInfo.description = description_;
        rentalInfo.category = category_;
        rentalInfo.imagesURL = imagesUrl_;
        rentalInfo.capacity = capacity_;
        rentalInfo.pricePerNight = pricePerNight_;
    }

    function checkAvailability(uint256 start, uint256 end) external view returns (bool) {
        require(start % 1 days == 0, "Start not equal to midnight");
        require(end % 1 days == 0, "End not equal to midnight");
        require(start < end, "End is earlier than start");

        Season memory season = seasons[currentSeason];
        require(start > season.start && end < season.end, "Out of season");

        uint256 startDay = 1 << (((start - season.start) / 1 days) - 1);
        uint256 numberNights = (end - start) / 1 days;
        uint256 mask = ((1 << numberNights) - 1) << startDay;

        if ((_bitCalendars[currentSeason] & mask) == 0) {
            return true;
        }

        return false;
    }

    function endTime(uint256 tokenId) external view returns (uint256) {
        if (_ownerOf(tokenId) == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return _reservations[tokenId].end;
    }

    function expiryType() external pure returns (EXPIRY_TYPE) {
        return IERC7858.EXPIRY_TYPE.TIME_BASED;
    }

    function getInfo() external view returns (RentalInfo memory) {
        return rentalInfo;
    }

    function isTokenExpired(uint256 tokenId) external view returns (bool) {
        if (_ownerOf(tokenId) == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        uint256 startTimeCache = _reservations[tokenId].start;
        uint256 endTimeCache = _reservations[tokenId].end;
        // if start and end is {0, 0} mean token non-expirable and return false.
        if (startTimeCache == 0 && endTimeCache == 0) {
            return false;
        } else {
            return block.timestamp >= endTimeCache;
        }
    }

    function reserve(address customer, uint256 start, uint256 numberNights) external payable {
        require(customer != address(0), "Customer is zero");
        require(start % 1 days == 0, "Start not equal to midnight");
        require(numberNights > 0 && numberNights <= 256, "Number of nights is out of range");
        require(msg.value >= reservationCost(numberNights), "Insufficient payment");

        Season memory season = seasons[currentSeason];
        uint256 end = season.start + numberNights * 1 days;
        require(start > season.start && end < season.end, "Out of season");

        uint256 startDay = 1 << (((start - season.start) / 1 days) - 1);
        uint256 mask = ((1 << numberNights) - 1) << startDay;

        uint256 calendar = _bitCalendars[currentSeason];

        if ((calendar & mask) != 0) {
            revert("Reservation overlaps");
        }

        _bitCalendars[currentSeason] = calendar | mask;

        _tokenIdCounter += 1;

        uint256 tokenId = _tokenIdCounter;

        _reservations[tokenId] = Reservation({customer: customer, start: start, end: end});

        _safeMint(customer, tokenId);

        emit TokenExpiryUpdated(tokenId, start, end);
    }

    function startTime(uint256 tokenId) external view returns (uint256) {
        if (_ownerOf(tokenId) == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return _reservations[tokenId].start;
    }

    function setNewSeason(uint256 year, uint256 start, uint256 numberNights) external onlyOwner {
        require(year > 0, "Year is zero");
        require(seasons[year].start == 0, "Season exists");
        require(start > block.timestamp, "New season in past");
        require(start % 1 days == 0, "Start not equal to midnight");
        require(numberNights > 0 && numberNights <= 256, "Number of nights is out of range");

        uint256 end = start + numberNights * 1 days;

        seasons[year] = Season({start: start, end: end, numberDays: numberNights});
    }

    function setCurrentSeason(uint256 year) external onlyOwner {
        require(seasons[year].start != 0, "Season exists");
        require(year > currentSeason, "Season is past");

        currentSeason = year;
    }

    function updateCapacity(uint256 newCapacity) external onlyOwner {
        require(newCapacity > 0, "Invalid capacity");

        rentalInfo.capacity = newCapacity;
    }

    function updateCategory(string calldata newCategory) external onlyOwner {
        rentalInfo.category = newCategory;
    }

    function updateImagesUrl(string calldata newImagesUrl) external onlyOwner {
        require(bytes(newImagesUrl).length > 0, "Invalid images URL");

        rentalInfo.imagesURL = newImagesUrl;
    }

    function updateDescriptions(string calldata newDescription) external onlyOwner {
        rentalInfo.description = newDescription;
    }

    function updatePricePerNight(uint256 newPricePerNight) external onlyOwner {
        require(newPricePerNight > 0, "Invalid price per night");

        rentalInfo.pricePerNight = newPricePerNight;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function reservationCost(uint256 numberNights) public view returns (uint256) {
        // Calculate the cost of the reservation based on the duration
        // and any other pricing factors specific to your use case
        return numberNights * rentalInfo.pricePerNight;
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == type(IERC7858).interfaceId || super.supportsInterface(interfaceId);
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("Soulbound: Transfer failed");
        }

        super._update(to, tokenId, auth);
    }
}
