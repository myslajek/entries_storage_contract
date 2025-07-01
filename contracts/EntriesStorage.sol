// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;


contract EntriesStorage {
    constructor() {
        contractOwner = msg.sender;
    }

    struct Entry {
        string value;
        uint256 timestamp;
        address author;
    }

    Entry[] private entries;

    address public contractOwner;
    
    mapping(address => bool) public contractManagers;
    
    event EntryAdded(address indexed user, string value, uint256 index);
    event EntryRemoved(address indexed manager, uint256 index, string value);
    event ManagerAdded(address indexed contractOwner, address indexed newManager);
    event ManagerRemoved(address indexed contractOwner, address indexed removedManager);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can do this operation");
        _;
    }
    
    modifier onlyManagerOrOwner() {
        require(contractManagers[msg.sender] || msg.sender == contractOwner, "No permission to manage");
        _;
    }
    
    function addEntry(string memory _value) public returns (bool){
        require(bytes(_value).length > 0, "Entry cannot be empty");
        require(bytes(_value).length <= 1000, "Entry too long"); 
        require(entries.length < 1000000, "Maximum entries reached"); 
 
        Entry memory newEntry =  Entry({
            value: _value,
            timestamp: block.timestamp,
            author: msg.sender
        });
        
        entries.push(newEntry);

        emit EntryAdded(msg.sender, _value, entries.length - 1);

        return true;
    }

    function getAllEntries() public view returns (Entry[] memory) {
        return entries;
    }
    
    function getEntries(uint256 offset, uint256 limit) public view returns (Entry[] memory) {
         require(offset < entries.length, "Offset out of bounds");
        require(limit > 0, "Limit must be greater than 0");
        require(limit <= 100, "Limit too high"); // Max 100 entries per call
        
        uint256 end = offset + limit;
        if (end > entries.length) {
            end = entries.length;
        }
        
        uint256 resultLength = end - offset;
        Entry[] memory result = new Entry[](resultLength);
        
        // Bounded loop with explicit limit check
        for (uint256 i = 0; i < resultLength; i++) {
            result[i] = entries[offset + i];
        }
        
        return result;
    }
    
    function getEntriesCount() public view returns (uint256) {
        return entries.length;
    }

    function removeEntry(uint256 _index)  onlyManagerOrOwner public returns (bool result) {
        require(_index < entries.length, "Invalid index");
        
        Entry memory removedValue = entries[_index];

        //Cheaper solution then sorting
        entries[_index] = entries[entries.length - 1];
        entries.pop();
        
        emit EntryRemoved(msg.sender, _index, removedValue.value);

        return true;
    }

    function getAllEntriesValues() public view returns (string[] memory) {
        string[] memory values = new string[](entries.length);
        for (uint256 i = 0; i < entries.length; i++) {
            values[i] = entries[i].value;
        }

        return values;
    }
    
    function clearAllStrings() public onlyManagerOrOwner returns (bool result){
        delete entries;

        return true;
    }

    function addManager(address _manager) public onlyOwner returns (bool){
        require(_manager != address(0), "Invalid Address");
        require(_manager != contractOwner, "Address is already a manager");
        require(!contractManagers[_manager], "Address is already a manager");
        
        contractManagers[_manager] = true;
        emit ManagerAdded(msg.sender, _manager);

        return true;
    }

    function removeManager(address _manager) public onlyOwner returns (bool){
        require(contractManagers[_manager], "Address is not a manager");
        
        contractManagers[_manager] = false;
        emit ManagerRemoved(msg.sender, _manager);

        return true;
    }

    function isManager(address _address) public view returns (bool) {
        return contractManagers[_address];
    }
    
    function transferOwnership(address _newOwner) public onlyOwner returns (bool){
        require(_newOwner != address(0), "Invalid address");
        require(_newOwner != contractOwner, "The address is an owner");
        
        address previousOwner = contractOwner;
        contractOwner = _newOwner;
        
        if (contractManagers[previousOwner]) {
            contractManagers[previousOwner] = false;
        }
        
        emit OwnershipTransferred(previousOwner, _newOwner);

        return true;
    }
}