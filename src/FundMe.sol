// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private addressToAmountFunded;
    address[] private s_funders;
    AggregatorV3Interface priceFeed ;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    
    constructor( address networkToDeploy) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(networkToDeploy);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        return priceFeed.version();
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    function cheaperWithdraw() public onlyOwner{
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex=0; funderIndex < fundersLength; funderIndex++){
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
         (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

        
    }
 

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
    /**
     * view / pure (getters)
     */
    function getAddressToAmountFunded( address fundingAddress) external view returns(uint256){
        return addressToAmountFunded[fundingAddress];
    } 
    function getFunders(uint256 index) external view returns (address)
    {
        return s_funders[index];
    }
    function getOwner() external view returns(address)
    {
        return i_owner;
    }

}



