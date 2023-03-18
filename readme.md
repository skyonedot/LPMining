log 两种方式
    emit或者console.log
记得加-vv 或者 -vvvv




.env contente
BN_RPC_URL=
PRIVATE_KEY=
ETHERSCAN_API_KEY=


forge script script/StakingRewards.s.sol:StakingRewardsScript --rpc-url $BN_RPC_URL --broadcast --verify -vvvv
