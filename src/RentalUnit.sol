// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {ERC721} from "solady/tokens/ERC721.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {IERC7858} from "./ERC7858/IERC7858.sol";
import {IRentalUnit} from "./IRentalUnit.sol";
import {Errors} from "./libs/Errors.sol";

contract RentalUnit is IRentalUnit, ERC721, IERC7858, Ownable {
    event Pause(address indexed account, bool indexed state);

    event RentalInfoUpdated();

    event SeasonSet(uint256 indexed seasonId, uint256 indexed start, uint256 indexed end);

    event WithdrawBalance();

    struct RentalInfo {
        string title;
        string symbol;
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
    mapping(uint256 seasonId => Season season) public seasons;
    mapping(uint256 seasonId => uint256 calendar) private _bitCalendars;
    mapping(uint256 tokenId => Reservation reservation) private _reservations;
    uint256 private _tokenIdCounter;
    uint256 private _currentSeason;
    uint256 private _seasonCounter;
    bool private _paused;

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
    ) {
        _initializeOwner(owner_);

        if (bytes(title_).length == 0) revert Errors.InvalidTitle();

        if (bytes(symbol_).length == 0) revert Errors.InvalidSymbol();

        if (bytes(country_).length == 0) revert Errors.InvalidCountry();

        if (bytes(city_).length == 0) revert Errors.InvalidCity();

        if (bytes(street_).length == 0) revert Errors.InvalidStreet();

        if (bytes(imagesUrl_).length == 0) revert Errors.InvalidImagesUrl();

        if (capacity_ == 0) revert Errors.InvalidCapacity();

        if (pricePerNight_ == 0) revert Errors.InvalidPricePerNight();

        rentalInfo.title = title_;
        rentalInfo.symbol = symbol_;
        rentalInfo.country = country_;
        rentalInfo.city = city_;
        rentalInfo.street = street_;
        rentalInfo.description = description_;
        rentalInfo.category = category_;
        rentalInfo.imagesURL = imagesUrl_;
        rentalInfo.capacity = capacity_;
        rentalInfo.pricePerNight = pricePerNight_;
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function addSeason(uint256 start, uint256 numberNights) external onlyOwner returns (uint256) {
        if (start <= block.timestamp) revert Errors.StartInPast();

        if (start % 1 days != 0) revert Errors.StartNotAtMidnight();

        if (numberNights == 0 || numberNights > 256) revert Errors.InvalidNumberOfNights();

        _seasonCounter += 1;

        uint256 seasonId = _seasonCounter;

        uint256 end = start + numberNights * 1 days;

        seasons[seasonId] = Season({start: start, end: end, numberDays: numberNights});

        return seasonId;
    }

    function pause() external onlyOwner {
        _setPause(true);
    }

    function reserve(address customer, uint256 start, uint256 numberNights) external payable {
        if (customer == address(0)) revert Errors.ZeroCustomer();

        if (start % 1 days != 0) revert Errors.StartNotAtMidnight();

        if (numberNights == 0 || numberNights > 256) revert Errors.InvalidNumberOfNights();

        if (msg.value < reservationCost(numberNights)) revert Errors.InsufficientPayment();

        Season memory season = seasons[_currentSeason];
        uint256 end = season.start + numberNights * 1 days;

        if (start <= season.start || end >= season.end) {
            revert Errors.OutOfSeason();
        }

        uint256 startDay = 1 << (((start - season.start) / 1 days) - 1);
        uint256 mask = ((1 << numberNights) - 1) << startDay;

        uint256 calendar = _bitCalendars[_currentSeason];

        if ((calendar & mask) != 0) {
            revert Errors.OverlappingReservation();
        }

        _bitCalendars[_currentSeason] = calendar | mask;

        _tokenIdCounter += 1;

        uint256 tokenId = _tokenIdCounter;

        _reservations[tokenId] = Reservation({customer: customer, start: start, end: end});

        _safeMint(customer, tokenId);

        emit TokenExpiryUpdated(tokenId, start, end);
    }

    function setCurrentSeason(uint256 seasonId) external onlyOwner {
        Season memory season = seasons[seasonId];

        if (season.start == 0) {
            revert Errors.SeasonNotExist();
        }

        _currentSeason = seasonId;

        emit SeasonSet(seasonId, season.start, season.end);
    }

    function updateCapacity(uint256 newCapacity) external onlyOwner {
        if (newCapacity == 0) revert Errors.InvalidCapacity();

        rentalInfo.capacity = newCapacity;

        emit RentalInfoUpdated();
    }

    function updateCategory(string calldata newCategory) external onlyOwner {
        rentalInfo.category = newCategory;

        emit RentalInfoUpdated();
    }

    function updateImagesUrl(string calldata newImagesUrl) external onlyOwner {
        if (bytes(newImagesUrl).length == 0) revert Errors.InvalidImagesUrl();

        rentalInfo.imagesURL = newImagesUrl;

        emit RentalInfoUpdated();
    }

    function updateDescriptions(string calldata newDescription) external onlyOwner {
        rentalInfo.description = newDescription;

        emit RentalInfoUpdated();
    }

    function updatePricePerNight(uint256 newPricePerNight) external onlyOwner {
        if (newPricePerNight == 0) revert Errors.InvalidPricePerNight();

        rentalInfo.pricePerNight = newPricePerNight;

        emit RentalInfoUpdated();
    }

    function unpause() external onlyOwner {
        _setPause(false);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);

        emit WithdrawBalance();
    }

    function checkAvailability(uint256 start, uint256 end) external view returns (bool) {
        if (start % 1 days != 0) revert Errors.StartNotAtMidnight();
        if (end % 1 days != 0) revert Errors.EndNotAtMidnight();
        if (start >= end) revert Errors.InvalidReservationPeriod();

        Season memory season = seasons[_currentSeason];
        if (start <= season.start || end >= season.end) {
            revert Errors.OutOfSeason();
        }

        uint256 startDay = 1 << (((start - season.start) / 1 days) - 1);
        uint256 numberNights = (end - start) / 1 days;
        uint256 mask = ((1 << numberNights) - 1) << startDay;

        if ((_bitCalendars[_currentSeason] & mask) == 0) {
            return true;
        }

        return false;
    }

    function endTime(uint256 tokenId) external view returns (uint256) {
        if (_ownerOf(tokenId) == address(0)) {
            revert Errors.ERC721NonexistentToken(tokenId);
        }
        return _reservations[tokenId].end;
    }

    function getInfo() external view returns (RentalInfo memory) {
        return rentalInfo;
    }

    function isTokenExpired(uint256 tokenId) external view returns (bool) {
        if (_ownerOf(tokenId) == address(0)) {
            revert Errors.ERC721NonexistentToken(tokenId);
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

    function startTime(uint256 tokenId) external view returns (uint256) {
        if (_ownerOf(tokenId) == address(0)) {
            revert Errors.ERC721NonexistentToken(tokenId);
        }
        return _reservations[tokenId].start;
    }

    function expiryType() external pure returns (EXPIRY_TYPE) {
        return IERC7858.EXPIRY_TYPE.TIME_BASED;
    }

    /*//////////////////////////////////////////////////////////////
                           PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function name() public view override returns (string memory) {
        return rentalInfo.title;
    }

    function symbol() public view override returns (string memory) {
        return rentalInfo.symbol;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }

    function reservationCost(uint256 numberNights) public view returns (uint256) {
        // Calculate the cost of the reservation based on the duration
        // and any other pricing factors specific to your use case
        return numberNights * rentalInfo.pricePerNight;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == type(IERC7858).interfaceId || super.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _beforeTokenTransfer(address from, address to, uint256 id) internal override {
        if (_paused) revert Errors.ReservationPaused();

        if (from != address(0) && to != address(0)) {
            revert Errors.SoulboundTransferNotAllowed();
        }
    }

    function _setPause(bool state) internal {
        _paused = state;
        emit Pause(msg.sender, state);
    }
}
