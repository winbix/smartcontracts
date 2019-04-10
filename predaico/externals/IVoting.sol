pragma solidity ^0.5.0;

import "../../utils/IOwnable.sol";

contract IVoting is IOwnable {

    uint public startDate;
    uint public endDate;
    uint public votesYes;
    uint public votesNo;
    uint8 public subject;
    uint public nextVotingDate;


    event InitVoting(uint startDate, uint endDate, uint8 subject);
    event Vote(address _address, int _vote);

    function initProlongationVoting() public;
    function initTapChangeVoting(uint8 newPercent) public;
    function inProgress() public view returns (bool);
    function yes(address _address, uint _votes) public;
    function no(address _address, uint _votes) public;
    function vote(address _address) public view returns (int);
    function votesTotal() public view returns (uint);
    function isSubjectApproved() public view returns (bool);
}
