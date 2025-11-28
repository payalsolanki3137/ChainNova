// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ChainNova
 * @dev Lightweight innovation/project registry with versioned metadata
 * @notice Teams register projects, attach versions, and toggle active status
 */
contract ChainNova {
    address public owner;

    struct Project {
        uint256 id;
        address creator;
        string  name;
        string  description;
        string  domain;       // e.g. "defi", "gaming", "infra"
        uint256 createdAt;
        bool    isActive;
    }

    struct Version {
        uint256 id;
        uint256 projectId;
        string  tag;          // e.g. "v1.0.0"
        string  metadataURI;  // spec, docs, deployment info
        uint256 createdAt;
    }

    uint256 public nextProjectId;
    uint256 public nextVersionId;

    // projectId => Project
    mapping(uint256 => Project) public projects;

    // versionId => Version
    mapping(uint256 => Version) public versions;

    // projectId => versionIds[]
    mapping(uint256 => uint256[]) public versionsOf;

    // creator => projectIds[]
    mapping(address => uint256[]) public projectsOf;

    event ProjectRegistered(
        uint256 indexed projectId,
        address indexed creator,
        string name,
        string domain,
        uint256 timestamp
    );

    event ProjectStatusUpdated(
        uint256 indexed projectId,
        bool isActive,
        uint256 timestamp
    );

    event VersionAdded(
        uint256 indexed versionId,
        uint256 indexed projectId,
        string tag,
        string metadataURI,
        uint256 timestamp
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier projectExists(uint256 projectId) {
        require(projects[projectId].creator != address(0), "Project not found");
        _;
    }

    modifier onlyCreator(uint256 projectId) {
        require(projects[projectId].creator == msg.sender, "Not project creator");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Register a new ChainNova project
     */
    function registerProject(
        string calldata name,
        string calldata description,
        string calldata domain
    ) external returns (uint256 projectId) {
        projectId = nextProjectId++;

        projects[projectId] = Project({
            id: projectId,
            creator: msg.sender,
            name: name,
            description: description,
            domain: domain,
            createdAt: block.timestamp,
            isActive: true
        });

        projectsOf[msg.sender].push(projectId);

        emit ProjectRegistered(projectId, msg.sender, name, domain, block.timestamp);
    }

    /**
     * @dev Toggle active flag for a project
     */
    function setProjectActive(uint256 projectId, bool active)
        external
        projectExists(projectId)
        onlyCreator(projectId)
    {
        projects[projectId].isActive = active;
        emit ProjectStatusUpdated(projectId, active, block.timestamp);
    }

    /**
     * @dev Add a new version (metadata snapshot) to a project
     */
    function addVersion(
        uint256 projectId,
        string calldata tag,
        string calldata metadataURI
    )
        external
        projectExists(projectId)
        onlyCreator(projectId)
        returns (uint256 versionId)
    {
        versionId = nextVersionId++;

        versions[versionId] = Version({
            id: versionId,
            projectId: projectId,
            tag: tag,
            metadataURI: metadataURI,
            createdAt: block.timestamp
        });

        versionsOf[projectId].push(versionId);

        emit VersionAdded(versionId, projectId, tag, metadataURI, block.timestamp);
    }

    /**
     * @dev Get all projectIds created by an address
     */
    function getProjectsOf(address creator) external view returns (uint256[] memory) {
        return projectsOf[creator];
    }

    /**
     * @dev Get all versionIds for a project
     */
    function getVersionsOf(uint256 projectId)
        external
        view
        projectExists(projectId)
        returns (uint256[] memory)
    {
        return versionsOf[projectId];
    }

    /**
     * @dev Transfer registry ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
