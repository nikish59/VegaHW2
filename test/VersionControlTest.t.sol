// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/VersionControl.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @notice Dummy-реализация для проверки обновления.
contract DummyImplementation is VersionControl {
    function getVersion() public pure returns (string memory) {
        return "Dummy V2";
    }
}

contract VersionControlTest is Test {
    VersionControl vc;
    address owner = address(1);
    address nonOwner = address(2);

    function setUp() public {
        // Развёртываем реализацию от имени owner
        vm.prank(owner);
        VersionControl versionControlImpl = new VersionControl();
        bytes memory data = abi.encodeWithSelector(VersionControl.initialize.selector);
        vm.prank(owner);
        ERC1967Proxy proxy = new ERC1967Proxy(address(versionControlImpl), data);
        vc = VersionControl(address(proxy));
    }

    function testInitialState() public {
        assertEq(vc.currentVersion(), address(vc));
        assertEq(vc.versionHistory(0), address(vc));
    }

    function testUpgradeToCustom() public {
        DummyImplementation dummy = new DummyImplementation();
        vm.prank(owner);
        vc.upgradeToCustom(address(dummy));
        assertEq(vc.versionHistory(1), address(dummy));
        assertEq(vc.currentVersion(), address(dummy));
    }

    function testRollbackToCustom() public {
        DummyImplementation dummy1 = new DummyImplementation();
        DummyImplementation dummy2 = new DummyImplementation();
        vm.prank(owner);
        vc.upgradeToCustom(address(dummy1)); 
        vm.prank(owner);
        vc.upgradeToCustom(address(dummy2)); 
        // Откатимся к dummy1 (индекс 1)
        vm.prank(owner);
        vc.rollbackToCustom(1);
        assertEq(vc.currentVersion(), address(dummy1));
    }

    function testUpgradeToZeroReverts() public {
        vm.prank(owner);
        vm.expectRevert("Invalid address");
        vc.upgradeToCustom(address(0));
    }

    function testOnlyOwnerUpgradeCustom() public {
        DummyImplementation dummy = new DummyImplementation();
        vm.prank(nonOwner);
        vm.expectRevert(); // ожидаем revert, если вызов не владельцем
        vc.upgradeToCustom(address(dummy));
    }

    function testOnlyOwnerRollbackCustom() public {
        DummyImplementation dummy = new DummyImplementation();
        vm.prank(owner);
        vc.upgradeToCustom(address(dummy));
        vm.prank(nonOwner);
        vm.expectRevert(); // ожидаем revert, если rollback вызывается не владельцем
        vc.rollbackToCustom(0);
    }
}
