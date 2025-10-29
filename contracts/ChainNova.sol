Transfer reward to innovator
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
// 
update
// 
