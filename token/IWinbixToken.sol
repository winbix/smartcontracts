pragma solidity ^0.5.0;

import "./IERC20Token.sol";

contract IWinbixToken is IERC20Token {

    uint256 public votableTotal;
    uint256 public accruableTotal;
    address public issuer;
    bool public transferAllowed;

    mapping (address => bool) public isPayable;

    event SetIssuer(address _address);
    event TransferAllowed(bool _newState);
    event FreezeWallet(address _address);
    event UnfreezeWallet(address _address);
    event IssueTokens(address indexed _to, uint256 _value);
    event IssueVotable(address indexed _to, uint256 _value);
    event IssueAccruable(address indexed _to, uint256 _value);
    event BurnTokens(address indexed _from, uint256 _value);
    event BurnVotable(address indexed _from, uint256 _value);
    event BurnAccruable(address indexed _from, uint256 _value);
    event SetPayable(address _address, bool _state);

    function setIssuer(address _address) public;
    function allowTransfer(bool _allowTransfer) public;
    function freeze(address _address) public;
    function unfreeze(address _address) public;
    function isFrozen(address _address) public returns (bool);
    function issue(address _to, uint256 _value) public;
    function issueVotable(address _to, uint256 _value) public;
    function issueAccruable(address _to, uint256 _value) public;
    function votableBalanceOf(address _address) public view returns (uint256);
    function accruableBalanceOf(address _address) public view returns (uint256);
    function burn(uint256 _value) public;
    function burnAll() public;
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool);
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool);
    function setMePayable(bool _state) public;
}
