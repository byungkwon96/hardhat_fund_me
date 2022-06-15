//Get funds from the users
//Withdraw funds
//Set a minimum funding value in USD

/* Solidity Code Style Guide
Order of layout: Pragama -> Import -> Interfaces -> Libraries -> Contracts
Contracts layout: Type declaration -> State variables -> events -> modifiers -> funcitons
NatSpec: Doxygen- /** @title,@author,@notice etc for automated documentations */

//SPDX-License-Identifier: MIT
//Pragma
pragma solidity ^0.8.8;

//Imports
import "./PriceConverter.sol";

//Error Codes
error FundMe__NotOwner();

//Interfaces, Libraries

//Contracts
//constant immutable can reduce the gas
/** @title A contract for crowd funding
 *  @notice demo a sample funding contract
 *  @dev This implements price feeds as our authors
 */
contract FundMe {
    //getConversionRate(msg.value) === msg.value.getConversionRate()
    //type declerations
    using PriceConverter for uint256;

    //assign compile time use constant keyword
    //State variables
    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmountFunded;

    //if variable gets sets one time use gas efficient method
    address public immutable i_owner;

    //Get price Feed address on different chain
    AggregatorV3Interface public s_priceFeed;

    //runs right after contract gets deployed
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // What happens if someone sends this contract ETH without using fund function
    // receive()
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    //get funds function
    //transaction has fields: Nonce, gasprice, gas limit, to, value, data, (v,r,s)
    //value transfer - gaslimit: 21000, to - address, data-empty
    //funciton call - to: address, data
    //payable - contracts address can hold funds
    function fund() public payable {
        //undo anything thats get reverted and give back remaining gas
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough"
        ); //1e18 == 1*10^18
        //msg.sender address of caller, msg.value -
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    //can put modifier at the end of the function
    function withdraw() public onlyOwner {
        //for loop and reset array
        for (
            uint256 fundersIndex = 0;
            fundersIndex < s_funders.length;
            fundersIndex++
        ) {
            address funder = s_funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset the array
        s_funders = new address[](0);

        //withdraw the funds (3 ways): transfer send call
        //1.transfer - cast address to payable address (automatically revert)
        //payable(msg.sender).transfer(address(this).balance);

        //2.send - don't revert needs to check with require
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed");

        //3.call - can use without an abi (returns 2 value)
        (
            bool callSuccess, /*bytes memory dataReturned*/

        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    //modifier runs before or after the function
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        } //gas-effcient
        //require(msg.sender == i_owner, "Sender is not owner");
        //do the rest of the code
        _;
    }

    //cheaper withdraw, because we copy array in function and use and store them later
    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 fundersIndex = 0;
            fundersIndex < funders.length;
            fundersIndex++
        ) {
            address funder = funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }
}
