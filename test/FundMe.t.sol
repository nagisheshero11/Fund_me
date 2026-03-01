// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address test = makeAddr("test");
    address alice = makeAddr("alice");
    uint256 constant SEND_VALUE = 1e18;
    uint256 constant Starting_Balance = 100 ether;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(test, Starting_Balance);
    }

    function testDemo() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public view {
        assertEq(fundme.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testEnoughEthTransfered() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundDatastuctureUpdate() public {
        vm.prank(test);
        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(test);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testfunderAddedToArray() public {
        vm.prank(test);
        fundme.fund{value: SEND_VALUE}();
        address curent = fundme.getFunder(0);
        assertEq(curent, test);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(test);
        fundme.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(test);
        fundme.withdraw();
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundme).balance;
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        assert(address(fundme).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundme.getOwner().balance
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                fundme.getOwner().balance - startingOwnerBalance
        );
    }

    modifier funded() {
    vm.prank(alice);
    fundme.fund{value: SEND_VALUE}();
    assert(address(fundme).balance > 0);
    _;
}

}
