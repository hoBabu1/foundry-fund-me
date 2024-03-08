//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run()external returns (FundMe) {
        HelperConfig activeConfig = new HelperConfig();
        address currAddress = activeConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundme = new FundMe(currAddress);
        vm.stopBroadcast();
        return fundme;
    }

}
