//SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;

import "./ERC20Token.sol";

contract Lending {
    Token public token;
    address public owner;

    struct Loan {
        address borrower;
        uint256 collateralAmount;
        uint256 loanAmount;
        uint256 interestRate;
        uint256 startTime;
        bool repaid;
    }

    mapping(adddress => Loan) public loans;

    event LoanRequested(
        address indexed borrower,
        uint256 collateralAMount,
        uint256 loanAmount
    );
    event LoanRepaid(address indexed borrower, uint256 amount);

    constructor(Token _token) {
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier activeLoan(address _borrower) {
        require(
            loans[_borrower].loanAmount > 0 && !loans[_borrower].repaid,
            "No active loan"
        );
        _;
    }

    function requestLoan(
        uint256 collateralAmount,
        uint256 loanAMount,
        uint256 interestRate
    ) external payable {
        require(
            loans[msg.sender].loanAmount == 0,
            "Existing loan must be repaid forst"
        );
        require(msg.value == collateralAmount, "Collateral amount mismatch");
        loans[msg.sender] = Loan({
            borrower: msg.sender,
            collateralAmount: collateralAmount,
            loanAmount: loanAmount,
            interestRate: interestRate,
            startTime: block.timestamp,
            repaid: false
        });
        require(
            token.transfer(msg.sender, loanAmount),
            "Token transfer failed"
        );

        emit LoanRequested(msg.sender, collateralAmount, loanAmount);
    }

    function repayLoan() external activeLoan(msg.sender) {
        Loan storage loan = loans[msg.sender];
        uint256 interest = (loan.loanAmount * loan.interestRate) / 100;
        uint256 totalRepayment = loan.loanAmount + interest;

        require(
            token.transferFrom(msg.sender, address(this), totalRepayment),
            "Token transfer failed"
        );
        loan.repaid = true;

        payable(msg.sender).transfer(loan.collateralAmount);
        emit LoanRepaid(msg.sender, totalRepayment);
    }
}
