// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        FundMe fundMeContract = new FundMe(helperConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return fundMeContract;
    }
}
