// SPDX-License-Identifier: MIT

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

pragma solidity ^0.8.4;

contract Dex {
    // using safe math from openzeppelin
    using SafeMath for uint;
    // States of User transaction action
    enum Side { 
        BUY,
        SELL        
    }
    // To add token
    struct Token {
        bytes32 Ticker;
        address tokenAddress;
    }
    // Required for LimitOrder
    struct Order {
        uint id;
        Side side;
        bytes32 ticker;
        uint amount;
        uint filled;
        uint price;
        address trader;
        uint date;
    }

    //event for marketorder
    event NewTrade(
        uint tradeId,
        uint orderId,
        bytes32 indexed ticker,
        address indexed trader1,
        address indexed trader2,
        uint amount,
        uint price,
        uint date
    );
    
    mapping(bytes32 => Token) public tokens;
    mapping(address => mapping(bytes32 => uint256)) public traderBalance;
    mapping(bytes32 => mapping(uint => Order[])) public OrderBook;

    address public admin;  
    bytes32[] tokenList;
    bytes32 constant DAI = bytes32("DAI");
    uint public nextOrderId;
    uint public nextTradeId; 

    constructor()  {
        admin = msg.sender;
    }
    // Dex is able to add crypto currency 
    function addToken(
        bytes32 ticker, address tokenaddr
        ) external {
        tokens[ticker] = Token(ticker, tokenaddr);
        tokenList.push(ticker);
    }
    // function to get Token already added
    function getToken() external view returns (Token[] memory) 
    {
            Token[] memory _tokens = new Token[](tokenList.length);
            for(uint i = 0; i < tokenList.length; i++)
            {
                _tokens[i] = Token(
                    tokens[tokenList[i]].Ticker,
                    tokens[tokenList[i]].tokenAddress
                );
            }
            return _tokens;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, 'you are not the owner');
        _;
    }
     

    modifier tokenExist(bytes32 ticker) {
        require(
            tokens[ticker].tokenAddress != address(0),
             'token does not exist');
        _;
    }
    function Deposit(uint amount, bytes32 ticker) 
            tokenExist(ticker) 
            external {
            IERC20(tokens[ticker].tokenAddress).transferFrom(
                msg.sender, address(this), amount);
            traderBalance[msg.sender][ticker] += amount;
    }
    //function to get Balance
    function getBalance(bytes32 ticker) external view returns (uint)
    {
        uint balance = traderBalance[msg.sender][ticker];
        return balance;
    }
    function withdraw(uint amount , bytes32 ticker) 
        tokenExist(ticker)
        external {
            require(traderBalance[msg.sender][ticker] >= amount,
            'you have not sufficient balance to withdraw / your balance is low');
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
    }
    // Function for LimitOrder 
    function createLimitOrder(
        bytes32 ticker,
        uint amount,
        uint price,
        Side side
        )tokenExist(ticker) external {
            require(ticker != bytes32('DAI'), 'cannot trade dai ');
        if(side == Side.SELL) {
            require(traderBalance[msg.sender][ticker] >= amount,'not enough token to sell');
        } else {
            require(traderBalance[msg.sender][bytes32('DAI')] >= amount * price , 'not enough balance to buy');
        }
        Order[] storage orders = OrderBook[ticker][uint(side)];
        orders.push(Order(
            nextOrderId,
            side,
            ticker,
            amount,
            0,
            price,
            msg.sender,
            block.timestamp
        ));
        uint i = orders.length - 1;

        while(i > 0){
            if(side == Side.BUY && orders[i - 1].price > orders[i].price ) {
                break;
            }

            if(side == Side.SELL && orders[i - 1].price < orders[i].price ) {
                break;
            }
            Order memory order = orders[i - 1];
            orders[i - 1] = orders[i];
            orders[i] = order;
            i--;
        }
        nextOrderId++;
    }

    // function to get token
    function getOrders(
        bytes32 ticker,
        Side side
    ) external view returns (Order[] memory)
    {
        return OrderBook[ticker][uint(side)];
    }
    // function to create marketorders
    function createMarketOrder(
        bytes32 ticker,
        uint amount,
        Side side
    )   
        tokenExist(ticker) 
        // modifier
        tokenIsNotDai(ticker)
        external {
            if(side == Side.BUY) {
                require(
                    traderBalance[msg.sender][ticker] >= amount,
                    'Insufficient token'
                    );
            }
            Order[] storage orders = OrderBook[ticker][uint(side == Side.BUY ? Side.SELL : Side.BUY)];
            uint i;
            uint remaining = amount;
            while(i > orders.length && remaining > 0) {
                uint available = orders[i].amount.sub(orders[i].filled);
                uint matched = (remaining > available) ? available : remaining;
                remaining = remaining.sub(matched);
                orders[i].filled = orders[i].filled.add(matched);

                emit NewTrade(
                    nextTradeId, 
                    orders[i].id , 
                    ticker, 
                    orders[i].trader,
                    msg.sender, 
                    matched,
                    orders[i].price,
                   block.timestamp
                   );
                
                if(side == Side.SELL) {
                    traderBalance[msg.sender][ticker] = traderBalance[msg.sender][ticker].sub(matched);
                    traderBalance[msg.sender][DAI] = traderBalance[msg.sender][DAI].add(matched.mul(orders[i].price));
                    traderBalance[orders[i].trader][ticker] = traderBalance[orders[i].trader][ticker].add(matched);
                    traderBalance[orders[i].trader][DAI] = traderBalance[orders[i].trader][DAI].sub(matched.mul(orders[i].price)); 
                }
                if(side == Side.BUY) {
                    require(
                        traderBalance[msg.sender][DAI] >= matched * orders[i].price,
                        'Dai balance is too low'
                    );
                    traderBalance[msg.sender][ticker] = traderBalance[msg.sender][ticker].add(matched);
                    traderBalance[msg.sender][DAI] = traderBalance[msg.sender][DAI].sub(matched.mul(orders[i].price));
                    traderBalance[orders[i].trader][ticker] = traderBalance[orders[i].trader][ticker].sub(matched);
                    traderBalance[orders[i].trader][DAI] = traderBalance[orders[i].trader][DAI].add(matched.mul(orders[i].price)); 
                }
                nextTradeId++;
                i++;
            }
            while(i < orders.length && orders[i].filled == orders[i].amount) {
                for(uint j = i; j < orders.length - 1; j++) {
                    orders[j] = orders[j+1];
                }
                orders.pop();
                i++;
            }
        }
        modifier tokenIsNotDai(bytes32 ticker) {
            require(
                ticker != DAI,
                 'Cannot trade DAI token'
                 );
            _;
        }
}   