//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {BagleToken} from "../src/BagleToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private amountToMint = 100 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagleToken) {
        vm.startBroadcast();
        BagleToken token = new BagleToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_root, token);
        token.mint(address(airdrop), amountToMint);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, BagleToken) {
        return deployMerkleAirdrop();
    }
}
