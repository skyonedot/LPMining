// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {StakingRewards} from "../src/StakingRewards.sol";
import {MyERC20} from "../src/ERC20.sol";

contract StakingRewardsTest is Test {
    MyERC20  tokenA;
    StakingRewards  stakingRewards;
    address  alice;
    address  bob;
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function setUp() public {
        tokenA = new MyERC20();
        stakingRewards = new StakingRewards(address(tokenA), address(tokenA), 100 ether) ;
        alice = address(0x1);
        bob = address(0x2);
        vm.deal(address(alice), 100 ether);
        vm.deal(address(bob), 100 ether);
        tokenA.mint(address(stakingRewards), 100000000 ether);
    }

    function test_Stake() public {
        tokenA.mint(address(alice), 10 ether);
        vm.prank(address(alice));
        tokenA.approve(address(stakingRewards), MAX_INT); 

        tokenA.mint(address(bob), 100 ether);
        vm.prank(address(bob));
        tokenA.approve(address(stakingRewards), MAX_INT);

        vm.warp(100);
        vm.prank(address(alice));
        stakingRewards.stake(10 ether);

        vm.warp(150);
        vm.prank(address(bob));
        stakingRewards.stake(100 ether);

        assertEq(stakingRewards.balanceOf(address(alice)), 10 ether);
        assertEq(stakingRewards.balanceOf(address(bob)), 100 ether);
        assertEq(stakingRewards.totalStaked(), 110 ether);

        vm.warp(170);
        vm.prank(address(alice));
        stakingRewards.withdraw(10 ether);
        vm.prank(address(alice));
        stakingRewards.claimReward();
        console.log("Alice Balance:%s",tokenA.balanceOf(address(alice))/1 ether);

        vm.warp(200);
        console.log("Alice Reward:%s",stakingRewards.earned(address(alice)) / 1 ether);
        console.log("Bob Reward:%s",stakingRewards.earned(address(bob)) / 1 ether);
    }
}