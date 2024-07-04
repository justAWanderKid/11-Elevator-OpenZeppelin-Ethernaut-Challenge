
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Elevator} from "../src/Elevator.sol";

contract DeployElevator is Script {

    Elevator elevator;

    function run() external returns(Elevator) {
        vm.startBroadcast();
        elevator = new Elevator();
        vm.stopBroadcast();
        return elevator;
    }

}