// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/VersionControl.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployVersionControl is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        VersionControl versionControlImpl = new VersionControl();

        bytes memory data = abi.encodeWithSelector(VersionControl.initialize.selector);

        ERC1967Proxy proxy = new ERC1967Proxy(address(versionControlImpl), data);

        console.log("Deployed VersionControl proxy at:", address(proxy));

        vm.stopBroadcast();
    }
}
