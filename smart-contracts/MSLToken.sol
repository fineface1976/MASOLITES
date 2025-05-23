// SPDX-License-Identifier: MIT
   pragma solidity ^0.8.0;

   contract MASOLToken {
       string public name = "MASOL";
       string public symbol = "MSL";
       uint256 public totalSupply = 10_000_000 * 10**18;
       uint256 public airdropAmount = 50 * 10**18;
       address public owner;

       mapping(address => uint256) public balances;

       constructor() {
           owner = msg.sender;
           balances[owner] = totalSupply;
       }

       function airdrop(address recipient) external {
           require(msg.sender == owner, "Only owner can airdrop");
           require(balances[owner] >= airdropAmount, "Insufficient balance");
           balances[owner] -= airdropAmount;
           balances[recipient] += airdropAmount;
       }
   }
