// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract Create {
    using Counters for Counters.Counter;

    Counters.Counter public _globalvoterId;
    Counters.Counter public _globalcandidateId;

    address public owner;

    ///Structure of a Candidate
    struct Candidate {
        uint256 candidateId;
        string age;
        string name;
        string image;
        uint256 voteCount;
        address _address;
    }
 
    //Create a list of addresses that stores the candidates
    address[] public candidateAddress; 

    //Map the addresses to Candidate structs
    mapping(address => Candidate) public candidates;


    //Structure of a Voter
    struct Voter {
        uint256 voter_voterId;
        address voter_address;
        uint256 voter_allowed;
        bool voter_voted;
        uint256 voted_to;
    }

    //Create a list of addresses that stores the voted voters
    address[] public votedVoters;

    //Create a list of addresses that stores the voter's eligible to vote addresses
    address[] public eligibleVoters;
    
    //Map the addresses to voter structs
    mapping(address => Voter) public voters;

    //FRONT END COMMUNICATION
    event CandidateCreate(
        uint256 indexed candidateId,
        string age,
        string name,
        string image,
        uint256 voteCount,
        address _address
    );

    event VoterCreated(
        uint256 indexed voter_voterId,
        address voter_address,
        uint256 voter_allowed,
        bool voter_voted,
        uint256 voted_to
    );

    
    //Set the contract owner to the deployer
    constructor() {
    owner = msg.sender;

    //Create Erdogan
    createCandidate(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, "69", "Recep Tayyip Erdogan", "img.png");

    //Create Kemal
    createCandidate(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, "74", "Kemal Kilicdaroglu", "img2.png");

    //Create 4 voters:
    createVoter(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
    createVoter(0x617F2E2fD72FD9D5503197092aC168c91465E7f2);
    createVoter(0x17F6AD8Ef982297579C203069C1DbfFE4348c372);
    createVoter(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678);

    }


    //// INITIALIZE CANDIDATES AND VOTERS ////
    function createCandidate(address _address, string memory _age, string memory _name, string memory _image) public {
        
        require(owner == msg.sender, "Only the deployer can set a candidate");

        _globalcandidateId.increment();

        uint256 idNumber = _globalcandidateId.current();

        //Retrieves the storage reference to the candidate associated with the provided _address
        Candidate storage candidate = candidates[_address];

        candidate.age = _age;
        candidate.name = _name;
        candidate.candidateId = idNumber;
        candidate.image = _image;
        candidate.voteCount = 0;
        candidate._address = _address;

        candidateAddress.push(_address);

        //Notify the front-end
        emit CandidateCreate(
            candidate.candidateId,
            candidate.age,
            candidate.name,
            candidate.image,
            candidate.voteCount,
            candidate._address
        );
    }

    function createVoter(address _address) public {
        require(owner == msg.sender, "You have no right to create a voter");

        _globalvoterId.increment();

        uint256 idNumber = _globalvoterId.current();

        //Retrieves the storage reference to the voter associated with the provided _address
        Voter storage voter = voters[_address];

        require(voter.voter_allowed == 0);

        voter.voter_allowed = 1;
        voter.voter_address = _address;
        voter.voter_voterId = idNumber;
        voter.voted_to = 0;
        voter.voter_voted = false;

        eligibleVoters.push(_address);
        
        //Notify the front-end
        emit VoterCreated(
            voter.voter_voterId,
            voter.voter_address,
            voter.voter_allowed,
            voter.voter_voted,
            voter.voted_to
        );
    }

    function vote(address _candidateAddress) external {
        Voter storage voter = voters[msg.sender];

        require(!voter.voter_voted, "You have already voted");
        require(voter.voter_allowed != 0, "You have no right to vote");

        voter.voter_voted = true;
        voter.voted_to = candidates[_candidateAddress].candidateId;

        votedVoters.push(msg.sender);

        candidates[_candidateAddress].voteCount += voter.voter_allowed;
    }


    //RETURN THE LISTS WITH ADDRESSES
    function getAllCandidateAdress() public view returns (address[] memory) {
        return candidateAddress;
    }

    function getVotedVotersList() public view returns (address[] memory) {
        return votedVoters;
    }

    function getEligibleVoterList() public view returns (address[] memory) {
        return eligibleVoters;
    }


    //RETURN THE LENGTH OF THE LISTS
    function getCandidatesLength() public view returns (uint256) {
        return candidateAddress.length;
    }

    function getVotedVotersLength() public view returns (uint256) {
        return votedVoters.length;
    }

    function getEligibleVoterLength() public view returns (uint256) {
        return eligibleVoters.length;
    }

    //GET DATA OF A STRUCT
    function getCandidateData(address _address) public view returns (string memory, string memory, uint256, string memory, uint256, address) {
        return (
            candidates[_address].age,
            candidates[_address].name,
            candidates[_address].candidateId,
            candidates[_address].image,
            candidates[_address].voteCount,
            candidates[_address]._address
        );
    }

    function getVoterData(address _address) public view returns (uint256, address, uint256, bool, uint256) {
        return (
            voters[_address].voter_voterId,
            voters[_address].voter_address,
            voters[_address].voter_allowed,
            voters[_address].voter_voted,
            voters[_address].voted_to
        );
    }
}
