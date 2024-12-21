// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SocialRewards {

    // Struct to represent a content post
    struct Post {
        uint256 id;
        address creator;
        uint256 likes;
        uint256 rewardAmount;
        bool isRewarded;
    }

    // State variables
    address public owner;
    uint256 public postCount;
    mapping(uint256 => Post) public posts;
    mapping(address => uint256) public balances;

    // Events
    event PostCreated(uint256 postId, address creator);
    event Liked(uint256 postId, address liker);
    event Rewarded(uint256 postId, uint256 rewardAmount, address creator);

    // Modifier to restrict certain actions to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
        postCount = 0;
    }

    // Create a new content post
    function createPost() external {
        postCount++;
        posts[postCount] = Post(postCount, msg.sender, 0, 0, false);
        emit PostCreated(postCount, msg.sender);
    }

    // Like a post, increasing the like count
    function likePost(uint256 postId) external {
        require(postId > 0 && postId <= postCount, "Invalid post ID");
        posts[postId].likes++;
        emit Liked(postId, msg.sender);
    }

    // Reward content creator based on likes
    function rewardCreator(uint256 postId) external onlyOwner {
        require(postId > 0 && postId <= postCount, "Invalid post ID");
        Post storage post = posts[postId];

        require(!post.isRewarded, "Post already rewarded");
        require(post.likes > 0, "Post has no likes");

        // Calculate reward (e.g., 1 token per like)
        uint256 reward = post.likes * 1 ether;  // 1 token per like (adjust as necessary)
        post.rewardAmount = reward;

        // Transfer reward to the creator
        balances[post.creator] += reward;
        post.isRewarded = true;

        emit Rewarded(postId, reward, post.creator);
    }

    // Allow the contract owner to fund the contract with tokens
    function fundContract() external payable onlyOwner {
        require(msg.value > 0, "Must send some ETH to fund the contract");
    }

    // Check the balance of a user (creator's reward)
    function checkBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    // Withdraw reward for the creator
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
