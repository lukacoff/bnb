//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {RentalUnit} from "./RentalUnit.sol";
import {RentalInfo} from "./RentalUnitStructs.sol";

contract RentalUintFactory {
    mapping(bytes32 => address) public deployedContracts;

    function deployRentalUnit(bytes32 _salt, address owner_, RentalInfo memory info_) external returns (address) {
        address rentalUnitAddr;

        if (deployedContracts[_salt] == address(0)) {
            rentalUnitAddr =
                Create2.deploy(0, _salt, abi.encodePacked(type(RentalUnit).creationCode, abi.encode(owner_, info_)));
            deployedContracts[_salt] = rentalUnitAddr;
        } else {
            rentalUnitAddr = computeTokenAddress(_salt, owner_, info_);
        }

        return rentalUnitAddr;
    }

    function computeTokenAddress(bytes32 _salt, address owner_, RentalInfo memory info_)
        public
        view
        returns (address)
    {
        return Create2.computeAddress(
            _salt, keccak256(abi.encodePacked(type(RentalUnit).creationCode, abi.encode(owner_, info_)))
        );
    }
}
