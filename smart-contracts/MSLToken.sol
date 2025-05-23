// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MASOLToken {
    string public name = "MASOL";
    string public symbol = "MSL";
    uint256 public totalSupply = 10_000_000 * 10**18; // 10 million tokens
    uint256 public airdropAmount = 50 * 10**18; // 50 tokens per user
    uint256 public icoStartDate;
    uint256 public constant ICO_DURATION = 60 days;
    uint256 public constant LAUNCH_PRICE = 0.2 * 10**18; // $0.2
    address public owner;

    // Track balances, referrals, and vesting
    mapping(address => uint256) public balances;
    mapping(address => address) public referrers;
    mapping(address => uint256) public vestingEndTime;
    mapping(address => uint256) public vestedAmount;

    // ICO daily price increase logic
    uint256 public constant BASE_PRICE = 0.001 * 10**18; // $0.001
    uint256 public constant FINAL_ICO_PRICE = 0.1 * 10**18; // $0.1
    uint256 public constant PRICE_INCREMENT = (FINAL_ICO_PRICE - BASE_PRICE) / 60;

    // Admin controls
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[owner] = totalSupply;
        icoStartDate = block.timestamp;
    }

    // Airdrop + MLM rewards (5% per level, 6 levels)
    function register(address referrer) external {
        require(balances[owner] >= airdropAmount, "Airdrop exhausted");
        balances[owner] -= airdropAmount;
        balances[msg.sender] += airdropAmount;
        
        // Distribute 5% rewards to upline (6 levels)
        address current = referrer;
        for (uint256 i = 0; i < 6; i++) {
            if (current == address(0)) break;
            uint256 reward = airdropAmount * 5 / 100;
            balances[current] += reward;
            balances[owner] -= reward;
            current = referrers[current];
        }
        
        referrers[msg.sender] = referrer;
    }

    // ICO price calculation
    function getCurrentPrice() public view returns (uint256) {
        if (block.timestamp > icoStartDate + ICO_DURATION) {
            return LAUNCH_PRICE; // $0.2 after day 60
        }
        uint256 daysPassed = (block.timestamp - icoStartDate) / 1 days;
        return BASE_PRICE + (daysPassed * PRICE_INCREMENT);
    }

    // Admin: Set vesting period (e.g., 5% APR for 6 months)
    function setVesting(address user, uint256 duration, uint256 interestRate) external onlyOwner {
        vestingEndTime[user] = block.timestamp + duration;
        vestedAmount[user] = balances[user] * (100 + interestRate) / 100;
    }
}
