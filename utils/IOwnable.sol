pragma solidity ^0.5.0;


contract IOwnable {

    address public owner;
    address public newOwner;

    event OwnerChanged(address _oldOwner, address _newOwner);

    function changeOwner(address _newOwner) public;
    function acceptOwnership() public;
}