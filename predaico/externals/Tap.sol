pragma solidity ^0.5.0;

import "../../utils/Ownable.sol";
import "./ITap.sol";

contract Tap is ITap, Ownable {

    function init(uint _baseEther, uint _startDate) public onlyOwner {
        require(baseEther == 0);
        baseEther = _baseEther;
        remainsForTap = _baseEther;
        nextTapDate = _startDate;
    }

    function changeNextTap(uint8 _newPercent) public onlyOwner {
        require(_newPercent <= 100);
        nextTapPercent = _newPercent;
    }

    function getNext() public onlyOwner returns (uint) {
        require(nextTapNum < 12);
        require(remainsForTap > 0);
        require(now >= nextTapDate);
        uint tapValue;
        if (nextTapNum == 11) {
            tapValue = remainsForTap;
        } else {
            tapValue = uint(nextTapPercent) * baseEther / 100;
            if (tapValue > remainsForTap) {
                tapValue = remainsForTap;
                nextTapNum = 11;
            }
        }
        remainsForTap -= tapValue;
        nextTapNum += 1;
        if (nextTapNum < 12) {
            nextTapPercent = tapPercents[nextTapNum];
            nextTapDate += 30 days;
        }
        return tapValue;
    }

    function subRemainsForTap(uint _delta) public onlyOwner {
        require(_delta <= remainsForTap);
        remainsForTap -= _delta;
    }
}