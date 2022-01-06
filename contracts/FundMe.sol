// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        // minimum $50
        // To be easy to test it without a lot of money in the wallet
        //        uint256 minimumUSD = 50 * 10 ** 18;
        //        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You aren't the owner");
        _;
    }

    function withdraw() public payable onlyOwner {
        // only want owner of the contract withdraw
        // moved to function definition up above        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

    // https://docs.chain.link/docs/price-feeds-api-reference/
    // Gives information about AggregatorV3Interface
    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    // the price is returned in wei units
    // 3862103280630000000000 ($3,862.10328063)
    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // multiplies the answer to set it in wei (18 parts of eth)
        // why we add 10 decimals? because answer is in 8 decimals
        return uint256(answer * 10000000000);
    }

    // Value to use when testing it: 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        // diveded by 100...000 because both values are in wei units
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // mimimumUSD
        uint256 mimimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (mimimumUSD * precision) / price;
    }
}
