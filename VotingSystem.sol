// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./IVote.sol";
import "./Candidates.sol";

contract VotingSystem is IVote, Candidates {
    // events
    event PersonVoted(address);
    event VotingEnded(
        Candidate winner,
        uint256 voteOne,
        uint256 voteTwo,
        uint256 voteThree
    );

    struct VotingInfo {
        bool hasVoted;
        Candidate thePersonVoted;
    }

    mapping(address => VotingInfo) private voters;
    address[] private votersAddress;

    uint256[3] private choices;
    uint256 private timeTillEnd;

    constructor(uint256 duration) {
        choices[0] = 0;
        choices[1] = 0;
        choices[2] = 0;

        timeTillEnd = block.timestamp + duration;
    }

    // modifiers
    modifier timeCheck() {
        require(timeTillEnd > block.timestamp, "Time has expired");
        _;
    }
    modifier correctCandidateVoted(uint8 _votedPerson) {
        require(_votedPerson > 0, "Candidate index between 0 and 3");
        require(_votedPerson < 3, "Candidate index between 0 and 3");
        _;
    }
    modifier hasAlreadyVoted() {
        require(voters[msg.sender].hasVoted == false, "Event already voted");
        _;
    }

    //Vote a person
    function VotePerson(uint8 _votedPerson)
        public
        override
        timeCheck
        correctCandidateVoted(_votedPerson)
        hasAlreadyVoted
    {
        voters[msg.sender].hasVoted = true;

        if (_votedPerson == 0) {
            voters[msg.sender].thePersonVoted = Candidate.LAVA_MINE;
            choices[0] = choices[0] + 1;
        }

        if (_votedPerson == 1) {
            voters[msg.sender].thePersonVoted = Candidate.INFINIT_ENERGY;
            choices[1] = choices[1] + 1;
        }

        if (_votedPerson == 2) {
            voters[msg.sender].thePersonVoted = Candidate.SUPER_SKIN_SALE;
            choices[2] = choices[2] + 1;
        }

        emit PersonVoted(msg.sender);
        votersAddress.push(msg.sender);
    }

    // See the total number of voters
    function ShowTotalVotersSoFar() public view returns (uint256) {
        return votersAddress.length;
    }

    // See what a certain address has voted
    function SeeWhatPersonVoted(address _userAddress)
        public
        view
        returns (Candidate)
    {
        return voters[_userAddress].thePersonVoted;
    }

    // See the results of the voting process
    function SeeResults()
        public
        returns (
            Candidate winner,
            uint256 voteOne,
            uint256 voteTwo,
            uint256 voteThree
        )
    {
        require(timeTillEnd < block.timestamp, "Voting has not yet finished");

        uint256 maximum = 0;
        Candidate theWinner;

        for (uint256 i = 0; i < 3; i++) {
            if (choices[i] > maximum) maximum = i;
        }

        if (maximum == 0) {
            theWinner = Candidate.LAVA_MINE;
        }
        if (maximum == 1) {
            theWinner = Candidate.INFINIT_ENERGY;
        }
        if (maximum == 2) {
            theWinner = Candidate.SUPER_SKIN_SALE;
        }

        emit VotingEnded(theWinner, choices[0], choices[1], choices[2]);

        return (theWinner, choices[0], choices[1], choices[2]);
    }
}
