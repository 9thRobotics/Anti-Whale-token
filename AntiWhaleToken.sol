// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AntiWhaleToken {
    string public name = "AntiWhaleToken";
    string public symbol = "AWT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10**uint256(decimals);
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public isExcludedFromLimits;

    uint256 public maxTransactionAmount = 1000 * 10**uint256(decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier antiWhale(address sender, address recipient, uint256 amount) {
        if (!isExcludedFromLimits[sender] && !isExcludedFromLimits[recipient]) {
            require(amount <= maxTransactionAmount, "Exceeds max transaction limit");
        }
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        isExcludedFromLimits[owner] = true;
    }

    function transfer(address recipient, uint256 amount)
        public
        antiWhale(msg.sender, recipient, amount)
        returns (bool)
    {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function setMaxTransactionAmount(uint256 _amount) external onlyOwner {
        maxTransactionAmount = _amount;
    }

    function excludeFromLimits(address account, bool excluded) external onlyOwner {
        isExcludedFromLimits[account] = excluded;
    }
}
