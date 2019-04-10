pragma solidity ^0.5.0;

import "../../utils/IOwnable.sol";
import "../../token/IWinbixToken.sol";
import "./ITap.sol";

contract IRefund is IOwnable {
    
    IWinbixToken public winbixToken;
    ITap public tap;
    uint public refundedTokens;
    uint public tokensBase;

    function init(address _token, uint _tokensBase, address _tap, uint _startDate) public;
    function refundEther(address payable _address, uint _value) public returns (uint);
    function calculateEtherForRefund(uint _tokensAmount) public view returns (uint);
}