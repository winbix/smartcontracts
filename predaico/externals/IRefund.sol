pragma solidity ^0.5.0;

import "../../utils/IOwnable.sol";
import "../../token/IWinbixToken.sol";
import "./ITap.sol";

contract IRefund is IOwnable {
    
    ITap public tap;
    uint public refundedTokens;
    uint public tokensBase;

    function init(uint _tokensBase, address _tap, uint _startDate) public;
    function refundEther(uint _value) public returns (uint);
    function calculateEtherForRefund(uint _tokensAmount) public view returns (uint);
}