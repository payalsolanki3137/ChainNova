// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ChainNova
 * @dev A decentralized innovation marketplace for idea submission, voting, and rewards
 */
contract ChainNova {
    
    struct Innovation {
        uint256 id;
        address innovator;
        string title;
        string description;
        uint256 voteCount;
        uint256 timestamp;
        bool isActive;
        uint256 rewardPool;
    }
    
    mapping(uint256 => Innovation) public innovations;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => uint256[]) public innovatorIdeas;
    
    uint256 public innovationCount;
    uint256 public constant MIN_REWARD = 0.01 ether;
    
    event InnovationSubmitted(uint256 indexed id, address indexed innovator, string title);
    event VoteCast(uint256 indexed innovationId, address indexed voter);
    event RewardDistributed(uint256 indexed innovationId, address indexed innovator, uint256 amount);
    
    /**
     * @dev Submit a new innovation idea
     * @param _title Title of the innovation
     * @param _description Detailed description of the innovation
     */
    function submitInnovation(string memory _title, string memory _description) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        
        innovationCount++;
        
        innovations[innovationCount] = Innovation({
            id: innovationCount,
            innovator: msg.sender,
            title: _title,
            description: _description,
            voteCount: 0,
            timestamp: block.timestamp,
            isActive: true,
            rewardPool: 0
        });
        
        innovatorIdeas[msg.sender].push(innovationCount);
        
        emit InnovationSubmitted(innovationCount, msg.sender, _title);
    }
    
    /**
     * @dev Vote for an innovation
     * @param _innovationId ID of the innovation to vote for
     */
    function voteForInnovation(uint256 _innovationId) public {
        require(_innovationId > 0 && _innovationId <= innovationCount, "Invalid innovation ID");
        require(innovations[_innovationId].isActive, "Innovation is not active");
        require(!hasVoted[_innovationId][msg.sender], "Already voted for this innovation");
        require(innovations[_innovationId].innovator != msg.sender, "Cannot vote for your own innovation");
        
        innovations[_innovationId].voteCount++;
        hasVoted[_innovationId][msg.sender] = true;
        
        emit VoteCast(_innovationId, msg.sender);
    }
    
    /**
     * @dev Reward an innovation with ETH
     * @param _innovationId ID of the innovation to reward
     */
    function rewardInnovation(uint256 _innovationId) public payable {
        require(_innovationId > 0 && _innovationId <= innovationCount, "Invalid innovation ID");
        require(innovations[_innovationId].isActive, "Innovation is not active");
        require(msg.value >= MIN_REWARD, "Reward must be at least minimum amount");
        
        innovations[_innovationId].rewardPool += msg.value;
        
        // Transfer reward to innovator
        payable(innovations[_innovationId].innovator).transfer(msg.value);
        
        emit RewardDistributed(_innovationId, innovations[_innovationId].innovator, msg.value);
    }
    
    /**
     * @dev Get innovation details
     * @param _innovationId ID of the innovation
     */
    function getInnovation(uint256 _innovationId) public view returns (
        uint256 id,
        address innovator,
        string memory title,
        string memory description,
        uint256 voteCount,
        uint256 timestamp,
        bool isActive,
        uint256 rewardPool
    ) {
        require(_innovationId > 0 && _innovationId <= innovationCount, "Invalid innovation ID");
        Innovation memory innovation = innovations[_innovationId];
        return (
            innovation.id,
            innovation.innovator,
            innovation.title,
            innovation.description,
            innovation.voteCount,
            innovation.timestamp,
            innovation.isActive,
            innovation.rewardPool
        );
    }
    
    /**
     * @dev Get all innovations by an innovator
     * @param _innovator Address of the innovator
     */
    function getInnovatorIdeas(address _innovator) public view returns (uint256[] memory) {
        return innovatorIdeas[_innovator];
    }
    
    /**
     * @dev Get total innovation count
     */
    function getTotalInnovations() public view returns (uint256) {
        return innovationCount;
    }
}
