// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Crowdfunding {
    struct Project {
        address creator;
        string description;
        uint256 goal;
        uint256 funds;
        uint256 deadline;
        bool funded;
        bool withdrawn;
    }

    Project[] public projects;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event ProjectCreated(
        address indexed creator,
        uint256 indexed projectId,
        string description,
        uint256 goal
    );
    event FundedProject(
        address indexed contributor,
        uint256 indexed projectId,
        uint256 amount
    );
    event WithdrawnFunds(address indexed creator, uint256 indexed projectId);

    function createProject(
        string memory description,
        uint256 goal,
        uint256 duration
    ) external {
        uint256 deadline = block.timestamp + duration;
        projects.push(
            Project({
                creator: msg.sender,
                description: description,
                goal: goal,
                funds: 0,
                deadline: deadline,
                funded: false,
                withdrawn: false
            })
        );

        emit ProjectCreated(msg.sender, projects.length - 1, description, goal);
    }

    function fundProject(uint256 projectId) external payable {
        Project storage project = projects[projectId];
        require(block.timestamp < project.deadline, "Funding period has ended");
        require(!project.funded, "Project already funded");

        project.funds += msg.value;
        contributions[projectId][msg.sender] += msg.value;

        if (project.funds >= project.goal) {
            project.funded = true;
        }

        emit FundedProject(msg.sender, projectId, msg.value);
    }

    function withdrawFunds(uint256 projectId) external {
        Project storage project = projects[projectId];
        require(
            msg.sender == project.creator,
            "Only project creator can withdraw"
        );
        require(project.funded, "Project not fully funded");
        require(!project.withdrawn, "Funds already withdrawn");

        project.withdrawn = true;
        payable(msg.sender).transfer(project.funds);

        emit WithdrawnFunds(msg.sender, projectId);
    }
}
