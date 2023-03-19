// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "forge-std/Test.sol";
import {MyERC20} from "../src/ERC20.sol";
import {StakingRewards} from "../src/StakingRewards.sol";

contract LpMiningTest is Test {
    //UniV2 mainnet Factory and Router address
    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address  alice;
    address  bob;
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    MyERC20  tokenA;
    MyERC20  tokenB;
    StakingRewards  stakingRewards;

    function setUp() public {
        tokenA = new MyERC20();
        tokenB = new MyERC20();
        alice = address(0x1);
        bob = address(0x2);
        vm.deal(address(alice), 100 ether);
        vm.deal(address(bob), 100 ether);
    }

    function test_CreatePair() public {
        address pairAddress = IUniswapV2Factory(FACTORY).createPair(address(tokenA), address(tokenB));
        assert(pairAddress != address(0));
    }

    function test_AddLiquidity() public {
        address pairAddress = IUniswapV2Factory(FACTORY).createPair(address(tokenA), address(tokenB));
        tokenA.mint(address(alice), 100 ether);
        tokenB.mint(address(alice), 100 ether);
        vm.prank(address(alice));
        tokenA.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        tokenB.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        IUniswapV2Router(ROUTER).addLiquidity(address(tokenA), address(tokenB), 100 ether, 100 ether, 0, 0, address(alice), block.timestamp);
        assertEq(tokenA.balanceOf(pairAddress), 100 ether);
        assertEq(tokenB.balanceOf(pairAddress), 100 ether);
        assertEq(IERC20(pairAddress).totalSupply(), 100 ether);
    }

    // 如果是Remove掉所有的Liquidity, 那么TokenA及TokenB, 是有1000 留在Pair这个Token地址里, 而Pair有1000, 是在第一个人添加流动性的时候, 就发送到0地址中的
    function test_RemoveLiquidity() public {
        address pairAddress = IUniswapV2Factory(FACTORY).createPair(address(tokenA), address(tokenB));
        tokenA.mint(address(alice), 100 ether);
        tokenB.mint(address(alice), 100 ether);
        vm.prank(address(alice));
        tokenA.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        tokenB.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        IUniswapV2Router(ROUTER).addLiquidity(address(tokenA), address(tokenB), 100 ether, 100 ether, 0, 0, address(alice), block.timestamp);
        assertEq(IERC20(pairAddress).balanceOf(address(0x0)), 1000);
        assertEq(tokenA.balanceOf(pairAddress), 100 ether);
        assertEq(tokenB.balanceOf(pairAddress), 100 ether);
        assertEq(IERC20(pairAddress).totalSupply(), 100 ether);

        uint liquidity = IERC20(pairAddress).balanceOf(address(alice));
        // console.log("Liquidity:%s",liquidity);
        vm.prank(address(alice));
        IERC20(pairAddress).approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        IUniswapV2Router(ROUTER).removeLiquidity(address(tokenA), address(tokenB), liquidity, 100 ether - 1000, 100 ether - 1000 , address(alice), block.timestamp);
        assertEq(tokenA.balanceOf(pairAddress), 1000);
        assertEq(tokenB.balanceOf(pairAddress), 1000);
        assertEq(IERC20(pairAddress).totalSupply(), 1000);
        assertEq(IERC20(pairAddress).balanceOf(address(alice)), 0);
        assertEq(IERC20(pairAddress).balanceOf(address(0x0)), 1000);
    }

    //上面removeliquidity时, 是最小出来100e - 1000, 但是如果是100e - 1000 + 1, 就会报错, 因为这个时候, 会出现tokenA的数量不够
    function testFail_RemoveLiquidity() public {
        address pairAddress = IUniswapV2Factory(FACTORY).createPair(address(tokenA), address(tokenB));
        tokenA.mint(address(alice), 100 ether);
        tokenB.mint(address(alice), 100 ether);
        vm.prank(address(alice));
        tokenA.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        tokenB.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        IUniswapV2Router(ROUTER).addLiquidity(address(tokenA), address(tokenB), 100 ether, 100 ether, 0, 0, address(alice), block.timestamp);

        uint liquidity = IERC20(pairAddress).balanceOf(address(alice));
        vm.prank(address(alice));
        IERC20(pairAddress).approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        IUniswapV2Router(ROUTER).removeLiquidity(address(tokenA), address(tokenB), liquidity, 100 ether - 1000+1, 100 ether - 1000+1 , address(alice), block.timestamp);
    }

    function test_MultiPeopleAddAndRemoveLiquidity() public {
        address pairAddress = IUniswapV2Factory(FACTORY).createPair(address(tokenA), address(tokenB));
        tokenA.mint(address(alice), 100 ether);
        tokenB.mint(address(alice), 100 ether);
        tokenA.mint(address(bob), 1000 ether);
        tokenB.mint(address(bob), 1000 ether);


        vm.prank(address(alice));
        tokenA.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        tokenB.approve(ROUTER, MAX_INT);

        vm.prank(address(bob));
        tokenA.approve(ROUTER, MAX_INT);
        vm.prank(address(bob));
        tokenB.approve(ROUTER, MAX_INT);

        //alice add liquidity
        vm.prank(address(alice));
        IUniswapV2Router(ROUTER).addLiquidity(address(tokenA), address(tokenB), 100 ether, 100 ether, 0, 0, address(alice), block.timestamp);
        assertEq(IERC20(pairAddress).balanceOf(address(0x0)), 1000);
        assertEq(tokenA.balanceOf(pairAddress), 100 ether);
        assertEq(tokenA.balanceOf(alice), 0);
        assertEq(tokenB.balanceOf(pairAddress), 100 ether);
        assertEq(tokenB.balanceOf(alice), 0);
        assertEq(IERC20(pairAddress).totalSupply(), 100 ether);
        assertEq(IERC20(pairAddress).balanceOf(alice), 100 ether - 1000, "alice's liquidity");


        //bob add liquidity
        vm.prank(address(bob));
        IUniswapV2Router(ROUTER).addLiquidity(address(tokenA), address(tokenB), 200 ether, 200 ether, 0, 0, address(bob), block.timestamp);
        assertEq(IERC20(pairAddress).balanceOf(address(0x0)), 1000);
        assertEq(tokenA.balanceOf(pairAddress), 300 ether);
        assertEq(tokenA.balanceOf(bob), 800 ether);
        assertEq(tokenB.balanceOf(pairAddress), 300 ether);
        assertEq(tokenB.balanceOf(bob), 800 ether);
        assertEq(IERC20(pairAddress).totalSupply(), 300 ether);
        assertEq(IERC20(pairAddress).balanceOf(bob), 200 ether);
    }

    //Lp stake, Mining TokenA
    function test_LpMining() public {
        address pairAddress = IUniswapV2Factory(FACTORY).createPair(address(tokenA), address(tokenB));
        tokenA.mint(address(alice), 100 ether);
        tokenB.mint(address(alice), 100 ether);
        tokenA.mint(address(bob), 1000 ether);
        tokenB.mint(address(bob), 1000 ether);

        vm.prank(address(alice));
        tokenA.approve(ROUTER, MAX_INT);
        vm.prank(address(alice));
        tokenB.approve(ROUTER, MAX_INT);
        vm.prank(address(bob));
        tokenA.approve(ROUTER, MAX_INT);
        vm.prank(address(bob));
        tokenB.approve(ROUTER, MAX_INT);

        vm.prank(address(alice));
        IUniswapV2Router(ROUTER).addLiquidity(address(tokenA), address(tokenB), 100 ether, 100 ether, 0, 0, address(alice), block.timestamp);
        vm.prank(address(bob));
        IUniswapV2Router(ROUTER).addLiquidity(address(tokenA), address(tokenB), 200 ether, 200 ether, 0, 0, address(bob), block.timestamp);
        uint alice_lp = IERC20(pairAddress).balanceOf(address(alice));
        uint bob_lp = IERC20(pairAddress).balanceOf(address(bob));

        //Start Stake LP Mining
        stakingRewards = new StakingRewards(pairAddress , address(tokenA), 10 ether);
        tokenA.mint(address(stakingRewards), 10 * 100 * 100 * 100 ether);

        vm.warp(0);
        vm.prank(address(alice));
        IERC20(pairAddress).approve(address(stakingRewards), MAX_INT);
        assertEq(IERC20(pairAddress).balanceOf(address(alice)), alice_lp, "Staking Pool Should Have All Alice LP");
        vm.prank(address(alice));
        stakingRewards.stake(alice_lp);
        assertEq(IERC20(pairAddress).balanceOf(address(alice)), 0, "Alice Should Have No LP");
        assertEq(stakingRewards.totalStaked(), alice_lp, "All totalStaked Should Be Alice LP");

        vm.warp(100);
        // console.log("Delta Percentage:%s",stdMath.percentDelta(stakingRewards.earned(address(alice)), 100*10 ether));
        // 误差小于1%
        assertEq(stdMath.percentDelta(stakingRewards.earned(address(alice)), 100*10 ether)<1 , true,"Alice Should Earned");

        vm.warp(200);
        vm.prank(address(bob));
        IERC20(pairAddress).approve(address(stakingRewards), MAX_INT);
        assertEq(IERC20(pairAddress).balanceOf(address(bob)), bob_lp, "Bob For Now Should Have All Bob LP");
        vm.prank(address(bob));
        stakingRewards.stake(bob_lp);
        assertEq(IERC20(pairAddress).balanceOf(address(bob)), 0, "Bob Should Have No LP");
        assertEq(stakingRewards.totalStaked(), alice_lp + bob_lp, "All totalStaked Should Be Alice LP + Bob LP");

        vm.warp(210);
        // console.log("Bob earned:%s", stakingRewards.earned(address(bob)));
        // console.log("Alice_lp:%s, Bob_lp:%s", alice_lp, bob_lp);
        // //这里的计算 会有精度问题 所以10ether中的ether, 往前提
        // console.log("Bob Earned in Calculate: %s", (bob_lp * 1 ether)/(bob_lp+alice_lp) * (210-200) * 10);
        // console.log("Alice Earned in Calculate: %s", (1 * (200 - 0) * 10 ether  + (alice_lp * 1 ether)/(bob_lp+alice_lp) * (210-200) * 10));
        // console.log("Alice Earned in Solidity: %s", stakingRewards.earned(address(alice)));
        assertEq(stdMath.percentDelta(stakingRewards.earned(address(bob)), (bob_lp * 1 ether)/(bob_lp+alice_lp) * (210-200) * 10) <1 , true,"Alice Should Earned");
        assertEq(stdMath.percentDelta(stakingRewards.earned(address(alice)), (1 * (200 - 0) * 10 ether  + (alice_lp * 1 ether)/(bob_lp+alice_lp) * (210-200) * 10)) <1 , true,"Alice Should Earned");

        vm.warp(300);
        vm.prank(address(alice));
        stakingRewards.claimReward();
        assertEq(stdMath.percentDelta(tokenA.balanceOf(address(alice)), (1 * (200 - 0) * 10 ether  + (alice_lp * 1 ether)/(bob_lp+alice_lp) * (300-200) * 10)) <1 , true,"Alice Get TokenA Reward");
        vm.prank(address(alice));
        stakingRewards.withdraw(alice_lp);
        assertEq(IERC20(pairAddress).balanceOf(address(alice)), alice_lp, "Alice Should Get Alice LP Back");
    }

    //上面最小值是   
}

interface IUniswapV2Factory {
    function getPair(address token0, address token1) external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Router {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
}
