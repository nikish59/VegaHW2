// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract VersionControl is UUPSUpgradeable, OwnableUpgradeable {
    // Массив для хранения истории реализаций
    address[] public versionHistory;
    address public currentVersion;

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        currentVersion = address(this);
        versionHistory.push(address(this));
    }

    /// @notice Функция обновления реализации с записью в историю.
    function upgradeToCustom(address newImplementation) external payable onlyOwner {
        require(newImplementation != address(0), "Invalid address");
        versionHistory.push(newImplementation);
        currentVersion = newImplementation;
        // Вызываем публичный метод обновления из UUPSUpgradeable (с 2-мя аргументами)
        super.upgradeToAndCall(newImplementation, bytes(""));
    }

    /// @notice Функция отката к ранее сохранённой версии.
    function rollbackToCustom(uint256 index) external payable onlyOwner {
        require(index < versionHistory.length, "Index out of range");
        address implementation = versionHistory[index];
        currentVersion = implementation;
        super.upgradeToAndCall(implementation, bytes(""));
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
