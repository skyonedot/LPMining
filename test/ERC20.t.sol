// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

// import {Test} from "forge-std/Test.sol";
// import {console} from "forge-std/console.sol";
// import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
import {MyERC20} from "../src/ERC20.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test{
    MyERC20 public erc20;

    function setUp() public {
        erc20 = new MyERC20();
        // erc20.mint(address(this), 100);
    }

    function test_MintToken() public {
        erc20.mint(address(this), 100);
        assertEq(erc20.balanceOf(address(this)), 100);
    }


}