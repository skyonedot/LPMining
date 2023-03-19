log 两种方式
    emit或者console.log
记得加-vv 或者 -vvvv




.env contente
BN_RPC_URL=
PRIVATE_KEY=
ETHERSCAN_API_KEY=


forge script script/StakingRewards.s.sol:StakingRewardsScript --rpc-url $BN_RPC_URL --broadcast --verify -vvvv


目前只实现了单币质押挖矿, 其实也等同于LP质押挖矿, 毕竟都是Token
但是还没实现的是 AddLiquidity这样
单币质押的核心 在于
1. userRewardPerTokenPaid 这个值只会在 同一个用户进行操作的时候, 才会update, 代表在这个时间段内的除了当前这段, 所有段的每1Token, 需要赚取多少的利息, 所以调用earned function的时候, 是((balanceOf[_account] *(rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) 这样计算出来的是, 在这一时间段内 用户所赚取的利息

2. rewardPerTokenStored 这个值是所有人都会update的同一个值 代表截止目前, 整个时间段内1Token能赚取多少的利息, (累加法嘛, 但凡有人操作的每个时间段内都会计算, 然后累加) 对应 rewardPerToken function

3. rewards是做累加的, 同一个人的两次操作才会update, 每次都是去累加上一次的奖励, 对应 earned function

重点去理解 rewardPerTokenStored 是针对所有人, 所有时间段内 1Token赚多少
而 userRewardPerTokenPaid 是计算除了当前这段, 前面所有段的盈利, 所以这两个一减, 则是当前段 1Token赚取利息

之所以 rewardPerTokenStored是全局update , 而userRewardPerTokenPaid 是mapping update, 是因为针对一个用户而言只需要考虑在这个时间段内, 1Token的盈利是多少, 
即rewardPerTokenStored 是经常update, 但是对于具体某一用户, 只需要知道一段时间内即可







Pair 即LP, 也是ERC20
Router 是做addliquidity, 计算, Mint出LP发送给用户的





-----------------------------
LP Mining

这里都可以用主网的几个地址来做, 
比如现在就可以Mint两个Token了 对吧
A,B 然后用主网的


forge test --match-path ./test/LpMining.t.sol -vvvv --rpc-url mainnetrpc