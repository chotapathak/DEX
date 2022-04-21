// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.4;

import './ERC20.sol';
contract BAT is ERC20 {
    constructor() ERC20('BAT', 'Basic attention token')  {

    }

    function faucet(address to,uint amount) external {
        _mint(to, amount);
    }
}