// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundme;
    address test = makeAddr("test");
    uint256 constant SEND_VALUE = 1e18;
    uint256 constant Starting_Balance = 100 ether;

    function setUp() public{
       DeployFundMe deployFundMe = new DeployFundMe();
       fundme = deployFundMe.run();
       vm.deal(test,Starting_Balance);
    }

    function testDemo() view public {
        assertEq(fundme.MINIMUM_USD(),5e18);
    }

    function testOwnerIsSender() view public{
        assertEq(fundme.i_owner(),msg.sender);
    }

    function testPriceFeedVersion() view public{
        uint256 version = fundme.getVersion();
        assertEq(version,4);
    }

    function testEnoughEthTransfered() public{
        vm.expectRevert();
        fundme.fund();
    }

    function testFundDatastuctureUpdate() public{
        vm.prank(test);
        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(test);
        assertEq(amountFunded,SEND_VALUE);
    }
    
}