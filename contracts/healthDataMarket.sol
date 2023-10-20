// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract healthDataMarket{

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    struct dataItem{
        uint256 dataId;
        string category;
        string name;
        string data;
        uint256 cost;
    }
    address public owner;

    struct Order{
        uint256 time;
        dataItem item;
    }

    mapping(uint256 => dataItem) public dataItems;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    constructor(){
        owner = msg.sender;
    }

    event Buy(address buyer,uint256 orderId, uint256 dataId);
    event AddData(string name, uint256 cost, string data);

    function addData(
        // Unique id for each record
        uint256 _id,
        string memory _name,
        string memory _category,
        // adding the hash we get by uploading the file into IPFS network
        string memory _data,
        uint256 _cost
    )public onlyOwner(){
        dataItem memory dataitem = dataItem(
            _id,
            _name,
            _category,
            _data,
            _cost
        );

        dataItems[_id] = dataitem;
        emit AddData(_name, _cost, _data);
    }

    function buy(uint256 _id) public payable{
        // getting the data by it's unique id
        dataItem memory dataitem = dataItems[_id];

        // Checking the balance before buying
        require(msg.value >= dataitem.cost);
        
        Order memory order = Order(block.timestamp,dataitem);
        orderCount[msg.sender]++; 

        orders[msg.sender][orderCount[msg.sender]] = order;
        emit Buy(msg.sender, orderCount[msg.sender], _id);
    }

    function access(uint256 _id) public view returns(
        string memory,
        string memory,
        string memory,
        uint256 cost)
        {
            dataItem memory dataitem = dataItems[_id];
            return(dataitem.category,dataitem.name,dataitem.data,dataitem.cost);
        }

    function withdraw() public onlyOwner{
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success);
    }
}