//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter
{
    //function to get the price of ethereum in usd
    function getUsdPrice(AggregatorV3Interface priceFeed) internal view returns(uint256)
    {
        //Address 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        (,int256 price,,,) = priceFeed.latestRoundData();
        //price of eth in usd
        //there is no decimal in the answer 300000000000, but we know there are 8 decimal digits
        //there is also a function in the aggregator contract that can return that info
        //we know value is in 1e18, so we multiply price by 1e10 for comparison.
        return uint256(price * 1e10);
    }

    //function to get version of the price feed
    /*function getVersion() internal view returns(uint256)
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version();
    }*/
    //function to get price conversion
    function getConversionRate(uint256 _ethAmount,AggregatorV3Interface priceFeed) internal view returns(uint256) 
    {
        uint256 ethPrice = getUsdPrice(priceFeed);
        uint256 ethAmountinUsd = (ethPrice * _ethAmount) / 1e18;
        return ethAmountinUsd;
    }
}