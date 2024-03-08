//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe , WithdrawFundMe} from "../../script/Interaction.s.sol";

contract fundMeTestIntegrtionTes is Test {
    FundMe fundme;
    address user = makeAddr("hoBabu");
    uint256 constant SEND_VALUE_IN_ETH = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(user, STARTING_BALANCE);
    }
     
    function testUserFundInteractions() public   {
        FundFundMe fundfundmee = new FundFundMe();
        fundfundmee.fundFundMe(address(fundme));

        WithdrawFundMe withdrawfundmee = new WithdrawFundMe();
        withdrawfundmee.withdrawFundMe(address(fundme));
         
        assertEq(address(fundme).balance,0);


    }
}
