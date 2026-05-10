// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import "../src/FundMe.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;
    function fundFundMe(address mostRecentlyDeployment) public {
        FundMe fundMeContract = FundMe(payable(mostRecentlyDeployment));
        fundMeContract.fund{value: SEND_VALUE}();
        console.log("FundMe funded! ");
    }
    function run() external {
        address fundMeAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(fundMeAddress);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {}
contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployment)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe!");
    }

    function run() external {
        address fundMeAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(fundMeAddress);
    }
}
