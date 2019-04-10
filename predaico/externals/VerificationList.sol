pragma solidity ^0.5.0;

import "./IVerificationList.sol";
import "../../utils/Ownable.sol";

contract VerificationList is IVerificationList, Ownable {

    enum States { NOT_IN_LIST, ON_CHECK, ACCEPTED, REJECTED }

    mapping (address => States) private states;

    modifier inList(address _address) {
        require(isInList(_address));
        _;
    }

    function isAccepted(address _address) public view returns (bool) {
        return states[_address] == States.ACCEPTED;
    }

    function isRejected(address _address) public view returns (bool) {
        return states[_address] == States.REJECTED;
    }

    function isOnCheck(address _address) public view returns (bool) {
        return states[_address] == States.ON_CHECK;
    }

    function isInList(address _address) public view returns (bool) {
        return states[_address] != States.NOT_IN_LIST;
    }
    
    function isNotInList(address _address) public view returns (bool) {
        return states[_address] == States.NOT_IN_LIST;
    }

    function isAcceptedOrNotInList(address _address) public view returns (bool) {
        return states[_address] == States.NOT_IN_LIST || states[_address] == States.ACCEPTED;
    }
    
    function getState(address _address) public view returns (uint8) {
        return uint8(states[_address]);
    }

    function accept(address _address) public onlyOwner inList(_address) {
        if (isAccepted(_address)) return;
        states[_address] = States.ACCEPTED;
        emit Accept(_address);
    }

    function reject(address _address) public onlyOwner inList(_address) {
        if (isRejected(_address)) return;
        states[_address] = States.REJECTED;
        emit Reject(_address);
    }

    function toCheck(address _address) public onlyOwner {
        if (isOnCheck(_address)) return;
        states[_address] = States.ON_CHECK;
        emit SendToCheck(_address);
    }

    function remove(address _address) public onlyOwner {
        if (isNotInList(_address)) return;
        states[_address] = States.NOT_IN_LIST;
        emit RemoveFromList(_address);
    }
}
