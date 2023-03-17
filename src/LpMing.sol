// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPStaking is Ownable {
    using SafeERC20 for IERC20;

    // The LP token being staked
    IERC20 public lpToken;

    // The reward token
    IERC20 public rewardToken;

    // The block number when farming starts
    uint256 public startBlock;

    // The block number when farming ends
    uint256 public endBlock;

    // The amount of reward tokens to be distributed per block
    uint256 public rewardPerBlock;

    // The total amount of LP tokens staked
    uint256 public totalStaked;

    // Mapping of user addresses to their staked LP balance
    mapping(address => uint256) public stakedBalances;

    // Mapping of user addresses to their last updated block
    mapping(address => uint256) public lastBlockUpdate;

    constructor(
        IERC20 _lpToken,
        IERC20 _rewardToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _rewardPerBlock
    ) {
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        startBlock = _startBlock;
        endBlock = _endBlock;
        rewardPerBlock = _rewardPerBlock;
    }

    function stake(uint256 _amount) external {
        require(block.number >= startBlock, "Staking hasn't started yet");
        require(block.number < endBlock, "Staking has ended");
        require(_amount > 0, "Cannot stake 0 tokens");

        // Update the user's staked balance and the total staked balance
        stakedBalances[msg.sender] += _amount;
        totalStaked += _amount;

        // Transfer the LP tokens from the user to the contract
        lpToken.safeTransferFrom(msg.sender, address(this), _amount);

        // Update the user's last block update
        lastBlockUpdate[msg.sender] = block.number;
    }

    function unstake(uint256 _amount) external {
        require(_amount > 0, "Cannot unstake 0 tokens");
        require(stakedBalances[msg.sender] >= _amount, "Insufficient staked balance");

        // Update the user's staked balance and the total staked balance
        stakedBalances[msg.sender] -= _amount;
        totalStaked -= _amount;

        // Transfer the LP tokens from the contract to the user
        lpToken.safeTransfer(msg.sender, _amount);

        // Update the user's last block update
        lastBlockUpdate[msg.sender] = block.number;
    }

    function claim() external {
        require(block.number >= startBlock, "Staking hasn't started yet");
        require(block.number >= endBlock, "Staking has ended");

        // Calculate the number of blocks since the user's last update
        uint256 blocksSinceLastUpdate = block.number - lastBlockUpdate[msg.sender];

        // Calculate the user's share of the rewards
        uint256 reward = stakedBalances[msg.sender] * rewardPerBlock * blocksSinceLastUpdate;

        // Transfer the reward tokens from the contract to the user
        rewardToken.safeTransfer(msg.sender, reward);

        // Update the user's last block update
        lastBlockUpdate[msg.sender] = block.number;
    }

    function emergencyWithdraw() external {
        lpToken.safeTransfer(msg.sender, stakedBalances[msg.sender]);
        stakedBalances[msg.sender] = 0;
        totalStaked -= stakedBalances[msg.sender];
        lastBlockUpdate[msg.sender] = block.number;
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        rewardPerBlock = _rewardPerBlock;
    }

    function setEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;
    }
}
