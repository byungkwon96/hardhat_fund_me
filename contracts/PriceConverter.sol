//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//can import directly from by using npm
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//library can't have state variables
//all functions will be internal
library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        // ABI of Contract & Address = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        //get ABI using interfaces
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return uint256(price * 1e10); //can typecast int and uint
    }

    // //interface + address can create ABI so we can use functions from other contracts
    // function getVersion() internal view returns (uint256) {
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(
    //         0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    //     );
    //     return priceFeed.version();
    // }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18; //multiply first
        return ethAmountInUsd;
    }
}
