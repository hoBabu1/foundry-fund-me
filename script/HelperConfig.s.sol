//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 constant _decimal = 8 ;
    int256 constant _initialAnswer = 2000e8;
    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return sepoliaConfig;
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {}

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0))
        {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mocksPricefeed = new MockV3Aggregator(_decimal, _initialAnswer);
        vm.stopBroadcast();
        NetworkConfig memory anvilconfig = NetworkConfig(address(mocksPricefeed));
        return anvilconfig;
    }
}
