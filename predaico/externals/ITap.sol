pragma solidity ^0.5.0;

import "../../utils/IOwnable.sol";

contract ITap is IOwnable {

    uint8[12] public tapPercents = [2, 2, 3, 11, 11, 17, 11, 11, 8, 8, 8, 8];
    uint8 public nextTapNum;
    uint8 public nextTapPercent = tapPercents[nextTapNum];
    uint public nextTapDate;
    uint public remainsForTap;
    uint public baseEther;

    function init(uint _baseEther, uint _startDate) public;
    function changeNextTap(uint8 _newPercent) public;
    function getNext() public returns (uint);
    function subRemainsForTap(uint _delta) public;
}