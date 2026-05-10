// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTests is Test {
    FundMe fundMeContract;
    // Forge Cheat code.
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMeContract = deployFundMe.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        // Give the script contract ETH so it can call fund{value: SEND_VALUE}()
        vm.deal(address(fundFundMe), STARTING_BALANCE);

        fundFundMe.fundFundMe(address(fundMeContract));

        // Since the script performed the funding, it is now the funder
        address funder = fundMeContract.getFunder(0);
        assertEq(funder, address(fundFundMe));
    }
}
