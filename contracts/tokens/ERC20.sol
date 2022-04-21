// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.4;

/// https://eips.ethereum.org/EIPS/eip-20

interface Token {

    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender  , uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20 is Token {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    uint256 public totalSupply;
    mapping(address => uint256) private _balances;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    string public name;                
    string public symbol;              
    uint256 private _totalSupply;
    constructor(string memory _tokenSymbol, string memory _tokenName) {      
        name = _tokenName;                                      
        symbol = _tokenSymbol;                                  
    }


     function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    // before check
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    // check after
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
