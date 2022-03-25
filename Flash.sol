// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "contracts/FlashLoanSimpleReceiverBase.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Flash is FlashLoanSimpleReceiverBase, Ownable {
    constructor(IPoolAddressesProvider _provider)
        FlashLoanSimpleReceiverBase(_provider)
    {}

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        uint256 _premium = amount + premium;

        IERC20(asset).approve(address(POOL), _premium);
        return true;
    }

    function flashBorrow(address _asset, uint256 _amount) external onlyOwner {
        address _receiverAddress = address(this);
        bytes memory _params = "";
        uint16 _referralCode = 0;

        POOL.flashLoanSimple(
            _receiverAddress,
            _asset,
            _amount,
            _params,
            _referralCode
        );
    }

    function withdraw(address _asset) external onlyOwner {
        uint256 _balance = IERC20(_asset).balanceOf(address(this));
        require(_balance > 0, "Wrong balance");
        IERC20(_asset).transfer(msg.sender, _balance);
    }
}
