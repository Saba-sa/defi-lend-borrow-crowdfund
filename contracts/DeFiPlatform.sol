// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Lending.sol";
import "./Crowdfunding.sol";

contract DeFiPlatform {
    Lending public lendingContract;
    Crowdfunding public crowdfundingContract;

    constructor(Lending _lendingContract, Crowdfunding _crowdfundingContract) {
        lendingContract = _lendingContract;
        crowdfundingContract = _crowdfundingContract;
    }
}
