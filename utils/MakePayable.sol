pragma solidity ^0.5.0;

contract MakePayable {
    function makePayable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }
}