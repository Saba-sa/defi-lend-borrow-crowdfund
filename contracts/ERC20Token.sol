// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 

contract ERC29Token is ERC20{
  address public admin;

  constructor(uint256 initialSupply) ERC20("DEFiToken","DET"){
    _mint(msg.sender,initialSupply);
    admin=msg.sender;
  }
  function mint(address to,uint256 amount)external{
    require(msg.sender==admin,"Only admin can mint tokens");
    _mint(to,amount);
  }
}
