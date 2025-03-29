// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {RentalInfo} from "../src/RentalUnitStructs.sol";
import {RentalUnitFactory} from "../src/RentalUnitFactory.sol";

contract RentalUnitFactoryTest is Test {
    RentalUnitFactory factory;
    address public owner = makeAddr("owner");

    RentalInfo validInfo;
    bytes32 salt = keccak256("gov");

    function setUp() public {
        factory = new RentalUnitFactory();

        validInfo = RentalInfo({
            title: "Slovak Villa",
            symbol: "TAX",
            country: "CROATIA",
            city: "Unknown",
            street: "Somewhere",
            description: "Paid by slovak citizens",
            category: "Luxury",
            imagesUrl: "ipfs://image",
            capacity: 10,
            pricePerNight: 1000
        });
    }

    function test_DeployRentalUnit_FirstTime() public {
        address deployed = factory.deployRentalUnit(salt, owner, validInfo);
        assertTrue(deployed != address(0), "Deployed address should not be zero");
        assertEq(factory.deployedContracts(salt), deployed);
    }

    function test_DeployRentalUnit_ReusesIfExists() public {
        address first = factory.deployRentalUnit(salt, owner, validInfo);
        address second = factory.deployRentalUnit(salt, owner, validInfo);
        assertEq(first, second, "Should return same contract address");
    }

    function test_ComputeTokenAddressMatchesDeployed() public {
        address predicted = factory.computeTokenAddress(salt, owner, validInfo);
        address deployed = factory.deployRentalUnit(salt, owner, validInfo);
        assertEq(predicted, deployed, "Predicted address should match actual");
    }
}
