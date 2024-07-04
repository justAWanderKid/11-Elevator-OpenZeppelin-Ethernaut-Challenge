// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBuilding {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        IBuilding building = IBuilding(msg.sender);


        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }

}