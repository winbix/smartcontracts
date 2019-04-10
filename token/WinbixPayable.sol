pragma solidity ^0.5.0;

import "./IWinbixPayable.sol";
import "./IWinbixToken.sol";

contract WinbixPayable is IWinbixPayable {

    IWinbixToken internal winbixToken;

    function winbixPayable(address payable _from, uint256 _value) internal;

    function catchWinbix(address payable _from, uint256 _value) external {
        require(address(msg.sender) == address(winbixToken));
        winbixPayable(_from, _value);
    }

}

