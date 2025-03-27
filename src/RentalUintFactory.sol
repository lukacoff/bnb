//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {RentalUnit} from "./RentalUnit.sol";

contract RentalUintFactory {
    mapping(bytes32 => address) public deployedContracts;

    function deployRentalUnit(
        bytes32 _salt,
        address owner_,
        string memory title_,
        string memory symbol_,
        string memory country_,
        string memory city_,
        string memory street_
    ) external returns (address) {
        address rentalUnitAddr;

        if (deployedContracts[_salt] == address(0)) {
            rentalUnitAddr = Create2.deploy(
                0,
                _salt,
                abi.encodePacked(
                    type(RentalUnit).creationCode, abi.encode(owner_, title_, symbol_, country_, city_, street_)
                )
            );
            deployedContracts[_salt] = rentalUnitAddr;
        } else {
            rentalUnitAddr = computeTokenAddress(_salt, owner_, title_, symbol_, country_, city_, street_);
        }

        return rentalUnitAddr;
    }

    function computeTokenAddress(
        bytes32 _salt,
        address owner_,
        string memory title_,
        string memory symbol_,
        string memory country_,
        string memory city_,
        string memory street_
    ) public view returns (address) {
        return Create2.computeAddress(
            _salt,
            keccak256(
                abi.encodePacked(
                    type(RentalUnit).creationCode, abi.encode(owner_, title_, symbol_, country_, city_, street_)
                )
            )
        );
    }
}
