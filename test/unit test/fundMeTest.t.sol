//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract fundMeTest is Test {
    FundMe fundme;
    address user = makeAddr("hoBabu");
    uint256 constant SEND_VALUE_IN_ETH = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(user, STARTING_BALANCE);
    }

    function testIsMinimumDollarIs5() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testisOwner() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testGetConversion() public {
        assertEq(fundme.getVersion(), 4);
    }

    function testFundsFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundme.fund();
    }

    modifier funded() {
        vm.prank(user); // It is saying that next txn will be carried by this address
        fundme.fund{value: SEND_VALUE_IN_ETH}();
        _;
    }

    function testFunctionUpdatesFundedDataStructure() public funded {
        assertEq(fundme.getFunders(0), user);
        assertEq(fundme.getAddressToAmountFunded(user), 10e18);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(user);
        vm.expectRevert();
        fundme.withdraw();
    }

    function test_Withdraw_With_SingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        //act

        vm.prank(fundme.getOwner());
        fundme.withdraw();
        //assert

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
      

         assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunder() public funded {
        // arrange 
        uint160 totalNumberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < totalNumberOfFunders; i++) {
            hoax(address(i), SEND_VALUE_IN_ETH);
            fundme.fund{value: SEND_VALUE_IN_ETH}();
        }
        // act
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();
        // assert 
        assertEq(address(fundme).balance, 0);
        assertEq(startingOwnerBalance+startingFundMeBalance , address(fundme.getOwner()).balance);
    }
    
}
