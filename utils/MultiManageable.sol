pragma solidity ^0.5.0;

import "./Ownable.sol";

contract MultiManageable is Ownable {

    uint16 constant MAX_MANAGERS_NUMBER = 100;

    address[] public managers;
    mapping(address => uint16) public managerByAddress;

    event AddManager(address manager);
    event RemoveManager(address manager);
    event ClearManagers();

    modifier onlyManager() {
        require(managerByAddress[msg.sender] > 0);
        _;
    }

    function isManager(address _address) public view returns (bool) {
        return managerByAddress[_address] > 0;
    }

    function addManager(address _manager) public onlyOwner {
        require(managers.length < MAX_MANAGERS_NUMBER);
        require(managerByAddress[_manager] == 0);
        managers.push(_manager);
        managerByAddress[_manager] = uint16(managers.length);
        emit AddManager(_manager);
    }

    function removeManager(address _manager) public onlyOwner {
        uint16 managerIndex = managerByAddress[_manager];
        require(managerIndex > 0);
        managerByAddress[_manager] = 0;
        if (managerIndex < managers.length) {
            address lastManager = managers[managers.length-1];
            managers[managerIndex - 1] = lastManager;
            managerByAddress[lastManager] = managerIndex;
        }
        managers.length -= 1;
        emit RemoveManager(_manager);
    }

    function clearManagers() public onlyOwner {
        for(uint16 i = 0; i < uint16(managers.length); i++) {
            managerByAddress[managers[i]] = 0;
        }
        managers.length = 0;
        emit ClearManagers();
    }

    function getManagers() public view returns (address[] memory) {
        return managers;
    }
}