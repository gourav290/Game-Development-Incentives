// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameDevelopmentIncentives {
    struct Contributor {
        address contributorAddress;
        uint256 contributions;
        uint256 rewards;
    }

    address public owner;
    mapping(address => Contributor) public contributors;
    uint256 public totalRewardsPool;

    event ContributionMade(address indexed contributor, uint256 amount);
    event RewardClaimed(address indexed contributor, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyContributor() {
        require(
            contributors[msg.sender].contributions > 0,
            "Only contributors can perform this action"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addFundsToPool() external payable onlyOwner {
        totalRewardsPool += msg.value;
    }

    function registerContribution(address contributorAddress, uint256 contributionAmount) external onlyOwner {
        contributors[contributorAddress].contributorAddress = contributorAddress;
        contributors[contributorAddress].contributions += contributionAmount;

        emit ContributionMade(contributorAddress, contributionAmount);
    }

    function calculateReward(address contributorAddress) public view returns (uint256) {
        uint256 totalContributions = 0;
        for (uint256 i = 0; i < contributors[contributorAddress].contributions; i++) {
            totalContributions += contributors[contributorAddress].contributions;
        }
        return
            (contributors[contributorAddress].contributions * totalRewardsPool) /
            totalContributions;
    }

    function claimReward() external onlyContributor {
        uint256 reward = calculateReward(msg.sender);
        require(reward <= totalRewardsPool, "Insufficient rewards pool");

        totalRewardsPool -= reward;
        contributors[msg.sender].rewards += reward;

        (bool success, ) = msg.sender.call{value: reward}("");
        require(success, "Reward claim failed");

        emit RewardClaimed(msg.sender, reward);
    }

    function withdrawUnusedFunds() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
