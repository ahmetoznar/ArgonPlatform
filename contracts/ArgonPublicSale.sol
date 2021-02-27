/**
 *Submitted for verification at BscScan.com on 2021-02-27
*/

pragma solidity ^0.4.17;

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

/**
ERC Token Standard #20 Interface
https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
*/
contract IERC20 {
    function totalSupply() public constant returns (uint256);

    function balanceOf(address tokenOwner)
        public
        constant
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        constant
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

/**
Contract function to receive approval and execute function in one call
Borrowed from MiniMeToken
*/
contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes data
    ) public;
}

contract ArgonPublicSale {
    address public manager; // ***BNB's destination address***

    bool public active; // ***Active ?***

    mapping(address => uint256) public investorsDepositedBNB; // ***All investors and their BNB deposits***

    mapping(address => uint256) public investorsDepositedARGON; // *** ARGON equivalent of all investors and BNB deposits ***

    mapping(address => bool) public isInvested;

    address[] public allInvestors; // ***All investors***

    uint256 public totalInvestmentARGON; // ***Total purchased ARGON***

    uint256 public totalInvestmentBNB; // ***Total BNB deposited***

    IERC20 public ArgonToken =
        IERC20(0x851f7a700c5d67db59612b871338a85526752c25); // ***ArgonToken Contract***

    uint256 public ARGONperBNB = 23333000000000000000000; // 1 BNB = 23333 ARGON

    uint256 public maxBNB = 1500000000000000000000; // ***Maximum BNB that can be deposited***

    uint256 public maxARGON = 35000000000000000000000000; // ***Maximum ARGON that can be purchased***

    constructor() public {
        manager = msg.sender; // ***Set Manager***
        active = false;
    }

    modifier isManager() {
        require(manager == msg.sender); // ***The transferring address must match the manager address.***
        _;
    }

    function changeActive(bool _active) public isManager {
        // ***Change Active***
        active = _active;
    }

    function buy() public payable returns (uint256) {
        require(active); // ***If Active***
        // ***Buy Tokens***
        require(totalInvestmentBNB + msg.value <= maxBNB); // ***BNB sent and total BNB deposited cannot be greater than the maximum BNB amount***
        require(
            totalInvestmentARGON +
                ((msg.value * ARGONperBNB) / 1000000000000000000) <=
                maxARGON
        ); // ***The sum of ARGON to be purchased and ARGON to be purchased cannot be greater than the ARGON to be sold.***
        require(msg.value >= 100000000000000000); // ***The BNB sent must be greater than 0.1 BNB.***
        require(
            investorsDepositedBNB[msg.sender] + msg.value <=
                10000000000000000000
        ); // ***The sum of the deposited and sent amount must be less than 10 BNB***

        uint256 argonamount = (msg.value * ARGONperBNB) / 1000000000000000000; // ***Amount of ArgonToken to be sent***

        investorsDepositedBNB[msg.sender] =
            investorsDepositedBNB[msg.sender] +
            msg.value; // ***Adding how many BNB the investor has deposited***
        investorsDepositedARGON[msg.sender] =
            investorsDepositedARGON[msg.sender] +
            argonamount; // ***Adding how many BNB equivalent ARGON the investor has deposited***

        if (isInvested[msg.sender]) {} else {
            // ***If no investment has been made***
            allInvestors.push(msg.sender); // ***Adding all investors***
            isInvested[msg.sender] = true; // ***Set Invested***
        }
        totalInvestmentBNB += msg.value; // ***Adding totalInvestmentBNB
        totalInvestmentARGON += argonamount; // ***Adding totalInvestmentARGON
    }

    function sendInvestorsTokens() public isManager {
        // ***Distribution of ARGON Token to investors.***
        for (uint256 i = 0; i < allInvestors.length; i++) {
            ArgonToken.transfer(
                allInvestors[i],
                investorsDepositedARGON[allInvestors[i]]
            );
        }
    }

    function getAllInvestors() public view returns (address[]) {
        return allInvestors;
    }

    function getARGONTokenDeployer(uint256 amount) public isManager {
        // ***Send ARGONTOKEN to DEPLOYER***
        ArgonToken.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) public isManager {
        // ***Send BNB to manager
        manager.transfer(amount);
    }

    function getAllBNB() public isManager {
        // Send all BNB's to manager
        manager.transfer(address(this).balance);
    }
}
