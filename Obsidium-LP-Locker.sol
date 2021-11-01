/*
* Contract written by @Anubis
* Tokenomics applicable with Selling tax 6%  - only applicable for 6 months (0% thereafter)
* 4.5% to liquidity pool | 1% to marketing wallet | 0.5% to ‘buyback’ wallet
* Name  - Obsidium | Symbol - OBS 
* MAX Supply -  14,5 millions
* Anti-dump Max Sell no more than 1.05% of supply over 24 hours – only applicable for 6 months (0% thereafter)
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 {
    uint256 public decimals;
}

contract XetaRealityLPLock {
    IERC20 private token;
    uint256 decimals;
    uint256 public lockedUntil = 0;
    address private tokenOwner;
    address private tokenAddress = 0xeb9b1df5e8e5f5b0dfadb80c24872c06baf58fbc;
    
    modifier onlyOwner() {
        require(msg.sender == tokenOwner, "Only contract owner can execute this");
        _;
    }
    
    constructor() {
        tokenOwner = msg.sender;
        token = IERC20(tokenAddress);
        decimals = ERC20(tokenAddress).decimals();
    }
    
    function lock(uint256 amount, uint256 until) public onlyOwner {
        require(token.balanceOf(tokenOwner) >= amount, "Amount larger than balance");
        require(token.allowance(tokenOwner, address(this)) >= amount, "Allowance must be larger than amount");
        require(until >= lockedUntil, "Relocking only allowed beyond current lock period");
        token.transferFrom(tokenOwner, address(this), amount);
        lockedUntil = until;
    }
    
    function unlock(uint256 amount) public onlyOwner {
        require(lockedAmount() > 0, "No locked amount");
        require(lockedAmount() >= amount, "Unlock amount larger than locked amount");
        require(block.timestamp > lockedUntil, "Locked period has not expired yet");
        token.transfer(tokenOwner, amount);
    }

    function lockedAmount() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}