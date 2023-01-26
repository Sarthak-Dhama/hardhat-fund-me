//A contract to get funds from users
//Withdraw funds to the address that deployed the contract
//Set a minimum fund value in USD

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe
{
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50 * 1e18;

    //array of addresses to record all the individuals who have funded the contract
    address[] public s_funders;

    //mapping to store the amount funded by the user
    mapping(address => uint256) public s_addressToAmountFunded;

    //adress of the owner
    address public immutable i_owner;

    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner
    {
        //require(msg.sender == i_owner, "Sender is not owner");
        if(msg.sender != i_owner)  revert FundMe__NotOwner(); 
        _;        
    }

    constructor(address priceFeedAddress)
    {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    //fund function for users to fund the contract
    function fund() public payable
    {
        //want to set a minimum fund value in usd
        //how to send eth or any crypto to this contract
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Not enough money");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    //function for the owner to withdraw funds
    function withdraw() public onlyOwner
    { 
        //loop to set amount in addressToAmountFunded to 0
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex = funderIndex + 1)
        {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value : address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    receive() external payable
    {
        fund();
    }

    fallback() external payable
    {
        fund();
    }
}