// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test{
    FundMe fundme;
    function setUp() public{
       fundme = new FundMe(address(0));
    }

    function testDemo() view public {
        assertEq(fundme.MINIMUM_USD(),5e18);
    }
    
}