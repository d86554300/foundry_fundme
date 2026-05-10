// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function testMinimumDollarIsFive() public {
        assertEq(fundMeContract.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        console.log("address(this):", msg.sender);
        console.log("SENDER:", msg.sender);
        console.log("Contract Owner: ", fundMeContract.getOwner());
        assertEq(fundMeContract.getOwner(), msg.sender);
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert();
        fundMeContract.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMeContract.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMeContract.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMeContract.fund{value: SEND_VALUE}();
        address funder = fundMeContract.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMeContract.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOWnerWithdraw() public funded {
        vm.expectRevert(); // next transaction should revert
        vm.prank(USER);
        fundMeContract.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 startingContractBalance = address(fundMeContract).balance;

        vm.prank(fundMeContract.getOwner());
        fundMeContract.withdraw();

        uint256 endingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 endingContractBalance = address(fundMeContract).balance;
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingContractBalance
        );
        assertEq(endingContractBalance, 0);
    }

    function testWithDrawWithMultipleSenders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMeContract.fund{value: SEND_VALUE}();
        }

        console.log("address(this):", msg.sender);
        console.log("SENDER:", msg.sender);
        console.log("Contract Owner: ", fundMeContract.getOwner());

        uint256 contractBalance = address(fundMeContract).balance;
        uint256 ownerBalance = fundMeContract.getOwner().balance;
        console.log("contractBalance: ", contractBalance);
        console.log("ownerBalance: ", ownerBalance);

        uint256 gasStart = gasleft();
        console.log("gasStart: ", gasStart);

        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMeContract.getOwner());
        fundMeContract.withdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gasUsed: ", gasUsed);

        console.log(
            "after withdraw - contractBalance: ",
            address(fundMeContract).balance
        );
        console.log(
            "after withdraw -  ownerBalance: ",
            fundMeContract.getOwner().balance
        );

        assertEq(address(fundMeContract).balance, 0);
        assertEq(
            fundMeContract.getOwner().balance,
            ownerBalance + contractBalance
        );
    }
}
