// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SimpleVoting {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }

    struct Proposal {
        string description;
        uint256 voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    address public administrator;

    WorkflowStatus public workflowStatus;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    uint256 private winningProposalId;

    modifier onlyAdministrator() {
        require(
            msg.sender == administrator,
            "the caller of this function must be the administrator"
        );
        _;
    }

    modifier onlyRegisteredVoter() {
        require(
            voters[msg.sender].isRegistered,
            "the caller of this function must be the voter"
        );
        _;
    }

    modifier onlyDuringVotersRegistration() {
        require(
            workflowStatus == WorkflowStatus.RegisteringVoters,
            "this function can be called only before proposals registration has started"
        );
        _;
    }

    modifier onlyDuringProposalRegistration() {
        require(
            workflowStatus == WorkflowStatus.ProposalsRegistrationStarted,
            "this function can be called only during proposlas registration"
        );
        _;
    }

    modifier onlyAfterProposalRegistration() {
        require(
            workflowStatus == WorkflowStatus.ProposalsRegistrationEnded,
            "this function can be called only after proposlas registration"
        );
        _;
    }

    modifier onlyDuringVotingSession() {
        require(
            workflowStatus == WorkflowStatus.VotingSessionStarted,
            "this function can be called only during the vote session"
        );
        _;
    }

    modifier onlyAfterVotingSession() {
        require(
            workflowStatus == WorkflowStatus.VotingSessionEnded,
            "this function can be called only after the vote session"
        );
        _;
    }

    modifier onlyAfterVotesTallied() {
        require(
            workflowStatus == WorkflowStatus.VotesTallied,
            "this function can be called only after votes have been tallied"
        );
        _;
    }

    event VoterRegisteredEvent(address voterAddress);
    event ProposalsRegistrationStartedEvent();
    event ProposalsRegistrationEndedEvent();
    event ProposalRegisteredEvent(uint256 proposalId);
    event VotingSessionStartedEvent();
    event VotingSessionEndedEvent();
    event VotedEvent(address voter, uint256 proposalId);
    event VotesTalliedEvent();

    event WorkflowStatusChangeEvent(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );

    constructor() public {
        administrator = msg.sender;
        workflowStatus = WorkflowStatus.RegisteringVoters;
    }

    function registerVoter(address _voterAddress)
        public
        onlyAdministrator
        onlyDuringVotersRegistration
    {
        require(
            !voters[_voterAddress].isRegistered,
            "The voter is already registered"
        );

        voters[_voterAddress].isRegistered = true;
        voters[_voterAddress].hasVoted = false;
        voters[_voterAddress].votedProposalId = 0;
    }

    function startProposalRegistration()
        public
        onlyAdministrator
        onlyDuringVotersRegistration
    {
        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;

        emit ProposalsRegistrationStartedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.RegisteringVoters,
            workflowStatus
        );
    }

    function endProposalRegistration()
        public
        onlyAdministrator
        onlyDuringVotersRegistration
    {
        workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;

        emit ProposalsRegistrationEndedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.ProposalsRegistrationStarted,
            workflowStatus
        );
    }

    function registerProposal(string memory proposalDescription)
        public
        onlyRegisteredVoter
        onlyDuringVotersRegistration
    {
        proposals.push(
            Proposal({description: proposalDescription, voteCount: 0})
        );

        emit ProposalRegisteredEvent(proposals.length - 1);
    }

    function vote(uint256 proposalId)
        public
        onlyRegisteredVoter
        onlyDuringVotingSession
    {
        require(!voters[msg.sender].hasVoted, "The caller has already voted");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = proposalId;

        proposals[proposalId].voteCount += 1;

        emit VotedEvent(msg.sender, proposalId);
    }

    function tallyVotes() public onlyAdministrator onlyAfterVotingSession {
        uint256 winningVoteCount = 0;
        uint256 winningProposalIndex = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }

        winningProposalId = winningProposalIndex;
        workflowStatus = WorkflowStatus.VotesTallied;
        emit VotesTalliedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.VotingSessionEnded,
            workflowStatus
        );
    }

    function getProposalNumber() public view returns (uint256) {
        return proposals.length;
    }

    function getProposalDescription(uint256 index)
        public
        view
        returns (string memory)
    {
        return proposals[index].description;
    }

    function getWinningProposalId()
        public
        view
        onlyAfterVotesTallied
        returns (uint256)
    {
        return winningProposalId;
    }

    function getWinningProposalDescription()
        public
        view
        onlyAfterVotesTallied
        returns (string memory)
    {
        return proposals[winningProposalId].description;
    }

    function getWinningProposalVoteCounts()
        public
        view
        onlyAfterVotesTallied
        returns (uint256)
    {
        return proposals[winningProposalId].voteCount;
    }

    function isRegisteredVoter(address _voterAddress)
        public
        view
        returns (bool)
    {
        return voters[_voterAddress].isRegistered;
    }

    function isAdministrator(address _address) public view returns (bool) {
        return _address == administrator;
    }

    function getWorkflowStatus() public view returns (WorkflowStatus) {
        return workflowStatus;
    }
}
