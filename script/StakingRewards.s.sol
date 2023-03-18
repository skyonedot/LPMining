// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/StakingRewards.sol";

contract StakingRewardsScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        StakingRewards stakingRewards = new StakingRewards(0x8F185f55e097F3670F72aD1d8fBdFdd3a46CA0B9, 0x8F185f55e097F3670F72aD1d8fBdFdd3a46CA0B9, 10 ether);

        vm.stopBroadcast();
    }
}
