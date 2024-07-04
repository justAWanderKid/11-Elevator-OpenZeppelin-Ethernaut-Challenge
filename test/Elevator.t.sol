
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Elevator, IBuilding} from "../src/Elevator.sol";
import {DeployElevator} from "../script/DeployElevator.sol";

contract ElevatorTest is Test {

    Elevator elevator;
    DeployElevator deployer;

    function setUp() external {
        deployer = new DeployElevator();
        elevator = deployer.run();
    }

    function testElevatorIsWorkingCorrectly() external {
        Building building = new Building(elevator);
        
        console.log("The Last Floor in this Building is 10.");
        console.log("Lets Use Elevator To Go To Floor 3.");

        building.useElevator(3);

        console.log("We Are Currently On Floor: ", elevator.floor());
        assertEq(elevator.floor(), 3);
        console.log("is This the Top of the Building? ", elevator.top());
        assertEq(elevator.top(), false);


        console.log("Hmm... i Changed my Mind, Lets Go To Top of the Building, Floor 10.");

        building.useElevator(10);

        console.log("We Are Currently On Floor: ", elevator.floor());
        assertEq(elevator.floor(), 10);
        console.log("is This the Top of the Building? ", elevator.top());
        assertEq(elevator.top(), true);
    }

}


contract Building is IBuilding {

    Elevator elevator;
    uint256 public lastFloor = 10;
    bool isFirstCall = true;

    constructor(Elevator _elevator) {
        elevator = _elevator;
    }

    function useElevator(uint256 _floor) external {
        elevator.goTo(_floor);
    }

    function isLastFloor(uint256 _floor) external returns (bool isLastFloorBoolean) {
        if (_floor != lastFloor) {
            isLastFloorBoolean = false;
        } else if (_floor == 10) {
            if (isFirstCall) {
                isFirstCall = false;
                return false;
            } else if (!isFirstCall) {
                isFirstCall = true;
                return true;
            }
        }
    }
}
