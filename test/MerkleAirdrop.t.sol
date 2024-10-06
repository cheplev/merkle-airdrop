//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Test, console2} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagleToken} from "../src/BagleToken.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public airdrop;
    BagleToken public token;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address public gasPayer;
    address user;
    uint256 userKey;
    uint256 constant AMOUNT_TO_CLAIM = 25 * 1e18;
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proof1, proof2];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagleToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(address(airdrop), AMOUNT_TO_CLAIM);
        }

        (user, userKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        console2.log("startingBalance", startingBalance);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        //sign a message
        // gasPayser call claim using th signed message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, proof, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console2.log("ending", endingBalance);
    }
}
