// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Voting {
    /**
     * 投票主题结构体
     */
    struct Theme {
        uint t_id;
        string t_name;
        string t_description;
        uint t_start_time;
        uint t_end_time;
        bool isActive;
        uint t_create_time;
        Candidate[] t_candidates;
        address[] t_voters;
    }

    /**
     * 候选人结构体
     */
    struct Candidate {
        uint c_id;
        string c_name;
        string c_description;
        uint c_vote_count;
        uint c_create_time;
    }
    // 主题map
    mapping(uint => Theme) public votingMaps;
    // 主题计数
    uint public votingCount;
    // 存储所有已创建的t_id
    uint[] public votingIds;  

    mapping(uint => mapping(address => bool)) public hasVoted;
      
    event VotingCreated(uint t_id, string t_name, string t_description, uint t_start_time, uint t_end_time, string[] _candidate_names);
    event Voted(address voter, uint t_id, uint c_id);

    function createVoting(string memory _t_name, string memory _t_description, uint _t_start_time, uint _t_end_time, string[] memory _candidate_names) public { 
        require(_candidate_names.length >0, "at least 2 candidates required");

        uint votingId = votingCount++;
        Theme storage theme = votingMaps[votingId];
        theme.t_id = votingId;
        theme.t_name = _t_name;
        theme.t_description = _t_description;
        theme.t_start_time = _t_start_time;
        theme.t_end_time = _t_end_time;
        theme.isActive = true;
        for (uint i = 0; i < _candidate_names.length; i++) { 
            theme.t_candidates.push(Candidate(i, _candidate_names[i], _candidate_names[i], 0, block.timestamp));
        }

        votingIds.push(votingId);
        emit VotingCreated(votingId, _t_name, _t_description, _t_start_time, _t_end_time, _candidate_names);
    }

    function vote (uint t_id, uint c_id) public {
        Theme storage theme = votingMaps[t_id];
        require(theme.isActive, "Voting is not active");
        require(theme.t_start_time <= block.timestamp , "Voting is not started yet");
        require(theme.t_end_time >= block.timestamp , "Voting is ended");
        require(hasVoted[t_id][msg.sender] == false, "You have already voted");

        theme.t_voters.push(msg.sender);
        theme.t_candidates[c_id].c_vote_count++;

        emit Voted(msg.sender, t_id, c_id);
    }

    function getVotingResult (uint t_id) public view returns (Candidate[] memory) {
        return votingMaps[t_id].t_candidates;
    }

    /**
     * Get all themes
     */
    function getAllThemeIds() public view returns (uint[] memory){
        return votingIds; 
    }

    /**
     * Get theme by id
     */
    function getThemeById(uint t_id) public view returns (Theme memory){
        return votingMaps[t_id];
    }

}