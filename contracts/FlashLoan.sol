// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashLoan is FlashLoanSimpleReceiverBase {
    using SafeMath for uint256;
    event Log(address asset, uint256 value);

    constructor(IPoolAddressesProvider provider) FlashLoanSimpleReceiverBase(provider) {}

    function createFlashLoan(address asset, uint amount) external {
        address receiver = address(this);
        // params => pass arbitrary data to executeOperation
        bytes memory params = "";
        uint16 referralCode = 0;

        // FlashLoanSimpleReceiverBase CONSTRUCTOR
        // constructor(IPoolAddressesProvider provider) {
        //     ADDRESSES_PROVIDER = provider;
        //     POOL = IPool(provider.getPool());
        // }

        // The pool.sol contract is the main user facing contract of the protocol.
        // It exposes the liquidity management methods that can be invoked using either Solidity or Web3 libraries.
        // https://docs.aave.com/developers/core-contracts/pool

        // params => Arbitrary bytes-encoded params that will be passed to executeOperation() method of the receiver contract.
        // refferalCode => used for 3rd party integration referral. The unique referral id is can be requested via governance proposal
        POOL.flashLoanSimple(receiver, asset, amount, params, referralCode);

        // Pool Contract will perform some checks
        // send the asset in the amount that was requested to the FlashLoanExample Contract
        // call the executeOperation method.
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        // Go crazy here, do things like arbitrage!
        // use abi.decode(params) to decode the params

        uint amountOwing = amount.add(premium);
        IERC20(asset).approve(address(POOL), amountOwing);

        emit Log(asset, amountOwing);

        return true;
    }
}
