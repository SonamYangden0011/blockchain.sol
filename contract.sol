// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Workshop {
    address public owner;
    uint256 public registrationFee;
    mapping(address => bool) public registered;
    mapping(address => bool) public attended;
    mapping(address => bool) public certified;

    event Registered(address indexed participant);
    event PaymentReceived(address indexed participant, uint256 amount);
    event Attended(address indexed participant);
    event Certified(address indexed participant);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyRegistered() {
        require(registered[msg.sender], "Not registered");
        _;
    }

    constructor(uint256 _registrationFee) {
        owner = msg.sender;
        registrationFee = _registrationFee;
    }

    // Register for the workshop
    function register() external payable {
        require(!registered[msg.sender], "Already registered");
        require(msg.value == registrationFee, "Incorrect registration fee");

        registered[msg.sender] = true;
        emit Registered(msg.sender);
        emit PaymentReceived(msg.sender, msg.value);
    }

    // Mark attendance for a participant
    function markAttendance(address participant) external onlyOwner onlyRegistered {
        require(registered[participant], "Participant not registered");
        attended[participant] = true;
        emit Attended(participant);
    }

    // Issue certification to a participant
    function issueCertificate(address participant) external onlyOwner onlyRegistered {
        require(attended[participant], "Participant has not attended");
        certified[participant] = true;
        emit Certified(participant);
    }

    // Withdraw contract balance (for owner)
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
    }
}
