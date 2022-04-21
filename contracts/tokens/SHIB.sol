// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.4;

import './ERC20.sol';
contract SHIB is ERC20 {
    constructor() ERC20('SHIB', 'Shiba inu')  {

    }

    function faucet(address to,uint amount) external {
        _mint(to, amount);
    }
}