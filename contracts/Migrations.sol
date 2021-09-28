// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Votes {
  struct Proposal{
    string description;
    uint voteCount;
  }

  struct Voter {
    bool isRegistered;
    bool hasVoted;
    uint votedProposalId;
  }

  enum WorkflowStatus{
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

  uint private winningProposalId;

  modifier onlyAdministrator() {
    require(msg.sender == administrator, "the caller of this function must be the administrator");
    _;
  }

  modifier onlyRegisteredVoter() {
    require(voters[msg.sender].isRegistered, "the caller of this function must be the voter");
    _;
  }

  modifier onlyDuringVotersRegistration(){
    require(workflowStatus == WorkflowStatus.RegisteringVoters, "this function can be called only before proposals registration has started");
    _;
  }

  modifier onlyDuringProposalRegistration(){
    require(workflowStatus == WorkflowStatus.ProposalsRegistrationEnded, "this function can be called only during proposlas registration");
    _;
  }

  event VoterRegisteredEvent (address voterAddress);
  event ProposalsRegistrationStartedEvent ();
  event ProposalsRegistrationEndedEvent ();
  event ProposalRegisteredEvent (uint proposalId);
  event VotingSessionStartedEvent ();
  event VotingSessionEndedEvent ();
  event VotedEvent (address voter, uint proposalId);
  event VotesTalliedEvent ();

  event WorkflowStatusChangeEvent(
    WorkflowStatus previousStatus,
    WorkflowStatus newStatus
  );

  constructor() public {
    administrator = msg.sender;
    workflowStatus = WorkflowStatus.RegisteringVoters;
  }

  function registerVoter(){}

  function startProposalRegistration(){}
  
  function endProposalRegistration(){}

  function registerProposal(){}

  function vote(){}

  function tallyVotes(){}

  function getProposalNumber(){}

  function getWinningProposalId(){}
  
  function isRegisteredVoter(){}

  function isAdmin(){}
  
  function getWorkflowStatus(){}
  
}
