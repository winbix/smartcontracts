pragma solidity ^0.5.0;

import "../../utils/Ownable.sol";
import "./IRefund.sol";


contract Refund is IRefund, Ownable {

    uint startDate;

    function init(uint _tokensBase, address _tap, uint _startDate) public onlyOwner {
        tap = ITap(_tap);
        tokensBase = _tokensBase;
        startDate = _startDate;
    }

    function refundEther(uint _value) public onlyOwner returns (uint) {
        uint etherForRefund = calculateEtherForRefund(_value);
        refundedTokens += _value;
        return etherForRefund;
    }

    function calculateEtherForRefund(uint _tokensAmount) public view returns (uint) {
        require(startDate > 0 && now > startDate && tokensBase > 0);
        uint etherRemains = tap.remainsForTap();
        if (_tokensAmount == 0 || etherRemains == 0) {
            return 0;
        }

        uint etherForRefund;

        uint startPart = refundedTokens + 1;
        uint endValue = refundedTokens + _tokensAmount;
        require(endValue <= tokensBase);

        uint refundCoeff;
        uint nextStart;
        uint endPart;
        uint partTokensValue;
        uint tokensRemains = tokensBase - refundedTokens;

        while (true) {
            refundCoeff = _refundCoeff(startPart);
            nextStart = _nextStart(refundCoeff);
            endPart = nextStart - 1;
            if (endPart > endValue) endPart = endValue;
            partTokensValue = endPart - startPart + 1;
            etherForRefund += refundCoeff * (etherRemains - etherForRefund) * partTokensValue / tokensRemains / 100;
            if (nextStart > endValue) break;
            startPart = nextStart;
            tokensRemains -= partTokensValue;
        }
        return etherForRefund;
    }

    function _refundCoeff(uint _tokensValue) private view returns (uint) {
        uint refundedPercent = 100 * _tokensValue / tokensBase;
        if (refundedPercent < 10) {
            return 80;
        } else if (refundedPercent < 20) {
            return 85;
        } else if (refundedPercent < 30) {
            return 90;
        } else if (refundedPercent < 40) {
            return 95;
        } else {
            return 100;
        }
    }

    function _nextStart(uint _refundCoefficient) private view returns (uint) {
        uint res;
        if (_refundCoefficient == 80) {
            res = tokensBase * 10 / 100;
        } else if (_refundCoefficient == 85) {
            res = tokensBase * 20 / 100;
        } else if (_refundCoefficient == 90) {
            res = tokensBase * 30 / 100;
        } else if (_refundCoefficient == 95) {
            res = tokensBase * 40 / 100;
        } else {
            return tokensBase+1;
        }
        if (_refundCoeff(res) == _refundCoefficient) res += 1;
        return res;
    }
}