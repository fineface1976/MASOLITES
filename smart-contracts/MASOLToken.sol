// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MASOLToken is ERC20, Ownable {
    uint256 public constant TOTAL_SUPPLY = 10_000_000 * 10**18;
    uint256 public constant AIRDROP_AMOUNT = 50 * 10**18;
    uint256 public icoStartTime;
    uint256 public constant ICO_DURATION = 60 days;
    uint256 public constant MIN_PURCHASE_START = 100 * 10**18; // 100 MSL
    uint256 public constant MIN_PURCHASE_END = 1 * 10**18; // 1 MSL
    uint256 public currentPrice = 0.001 * 10**18; // $0.001

    struct User {
        address upline;
        uint256 referrals;
    }

    mapping(address => User) public users;
    mapping(address => uint256) public vestingEndTime;
    mapping(address => uint256) public vestedAmount;

    event Registered(address indexed user, address indexed upline);
    event Airdropped(address indexed user, uint256 amount);

    constructor() ERC20("MASOL", "MSL") {
        _mint(owner(), TOTAL_SUPPLY);
        icoStartTime = block.timestamp;
    }

    // Register with upline (MLM logic)
    function register(address upline) external {
        require(users[msg.sender].upline == address(0), "Already registered");
        require(upline != msg.sender, "Invalid upline");

        users[msg.sender].upline = upline;
        users[upline].referrals++;

        // Airdrop 50 MSL
        _transfer(owner(), msg.sender, AIRDROP_AMOUNT);
        emit Airdropped(msg.sender, AIRDROP_AMOUNT);

        // Distribute 5% rewards to 6 levels
        address current = upline;
        for (uint256 i = 0; i < 6; i++) {
            if (current == address(0)) break;
            uint256 reward = AIRDROP_AMOUNT * 5 / 100;
            _transfer(owner(), current, reward);
            current = users[current].upline;
        }

        emit Registered(msg.sender, upline);
    }

    // Update ICO price daily
    function updatePrice() public onlyOwner {
        uint256 daysPassed = (block.timestamp - icoStartTime) / 1 days;
        currentPrice = 0.001 * 10**18 + (daysPassed * (0.1 * 10**18 - 0.001 * 10**18) / 60);
        if (daysPassed >= 60) currentPrice = 0.2 * 10**18;
    }

    // Admin: Set vesting (e.g., 5% APR for 6 months)
    function setVesting(address user, uint256 duration, uint256 rate) external onlyOwner {
        vestingEndTime[user] = block.timestamp + duration;
        vestedAmount[user] = balanceOf(user) * (100 + rate) / 100;
    }
}
