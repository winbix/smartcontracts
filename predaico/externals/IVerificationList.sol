pragma solidity ^0.5.0;

import "../../utils/IOwnable.sol";

contract IVerificationList is IOwnable {

    event Accept(address _address);
    event Reject(address _address);
    event SendToCheck(address _address);
    event RemoveFromList(address _address);
    
    function isAccepted(address _address) public view returns (bool);
    function isRejected(address _address) public view returns (bool);
    function isOnCheck(address _address) public view returns (bool);
    function isInList(address _address) public view returns (bool);
    function isNotInList(address _address) public view returns (bool);
    function isAcceptedOrNotInList(address _address) public view returns (bool);
    function getState(address _address) public view returns (uint8);
    
    function accept(address _address) public;
    function reject(address _address) public;
    function toCheck(address _address) public;
    function remove(address _address) public;
}