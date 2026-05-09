// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMeContract;
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMeContract = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMeContract.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        console.log("address(this):", msg.sender);
        console.log("SENDER:", msg.sender);
        console.log("Contract Owner: ", fundMeContract.i_owner());
        assertEq(fundMeContract.i_owner(), msg.sender);
    }
}
