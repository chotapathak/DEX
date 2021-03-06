// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.4;

import './ERC20.sol';
contract XRP is ERC20 {
    constructor() ERC20('XRP', 'Xrp is Ripple')  {

    }

    function faucet(address to,uint amount) external {
        _mint(to, amount);
    }
}