// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { IWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { ERC721Registry } from "@eveworld/world/src/codegen/tables/ERC721Registry.sol";
import { ERC721_REGISTRY_TABLE_ID } from "@eveworld/world/src/modules/eve-erc721-puppet/constants.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";
import { DeployableState, State } from "@eveworld/world/src/codegen/tables/DeployableState.sol";
import { SmartAssemblyTable, SmartAssemblyType } from "@eveworld/world/src/codegen/tables/SmartAssemblyTable.sol";
import { DeployableFuelBalance } from "@eveworld/world/src/codegen/tables/DeployableFuelBalance.sol";
import { ISmartDeployableSystem } from "@eveworld/world/src/modules/smart-deployable/interfaces/ISmartDeployableSystem.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";

bytes14 constant SMART_DEPLOYABLE_ERC721_NAMESPACE = "erc721deploybl";
string constant INPUT_DATA = "data/erc721deploybl__Owners.txt";

contract BulkStateManager is Script {
  using SmartDeployableLib for SmartDeployableLib.World;

  function bringAllTurretsOnline(address worldAddress) external {
    converge(worldAddress, SmartAssemblyType.SMART_TURRET, State.ONLINE);
  }

  function bringAllTurretsOffline(address worldAddress) external {
    converge(worldAddress, SmartAssemblyType.SMART_TURRET, State.ANCHORED);
  }

  function converge(address worldAddress, SmartAssemblyType targetType, State targetState) public {
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the keypair from the .env
    uint256 ownerPrivateKey = vm.envUint("PRIVATE_KEY");
    address ownerPublicKey = vm.envAddress("PUBLIC_KEY");

    console.log("Public Key:", ownerPublicKey);

    vm.startBroadcast(ownerPrivateKey);

    SmartDeployableLib.World memory smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    // Get the ERC-721 token address
    address tokenAddress = ERC721Registry.getTokenAddress(
      ERC721_REGISTRY_TABLE_ID,
      WorldResourceIdLib.encodeNamespace(SMART_DEPLOYABLE_ERC721_NAMESPACE)
    );
    console.log("Token Address:", tokenAddress);

    IERC721 token = IERC721(tokenAddress);

    uint256 balance = token.balanceOf(ownerPublicKey);

    console.log("Smart Deployable Balance :", balance);

    for (uint256 i = 0; i < balance; i++) {
      string memory tokenId = vm.readLine(INPUT_DATA);

      // skip header
      if (keccak256(bytes(tokenId)) == keccak256(bytes("tokenId"))) {
        continue;
      }

      // skip emppty
      if (keccak256(bytes(tokenId)) == keccak256(bytes(""))) {
        continue;
      }

      uint256 smartObjectId = vm.parseUint(tokenId);

      SmartAssemblyType assemblyType = SmartAssemblyTable.get(smartObjectId);

      if (assemblyType != targetType) {
        console.log("Skipping Token ID:", tokenId, "(Wrong Type)");
        continue;
      }

      State state = DeployableState.getCurrentState(smartObjectId);

      if (state == targetState) {
        console.log("Skipping Token ID:", tokenId, "(Already in Target State)");
        continue;
      }

      if (state == State.UNANCHORED) {
        console.log("Skipping Token ID:", tokenId, "(Unanchored)");
        continue;
      }

      if (state == State.DESTROYED) {
        console.log("Skipping Token ID:", tokenId, "(Destroyed)");
        continue;
      }

      uint256 fuelBalance = DeployableFuelBalance.getFuelAmount(smartObjectId);

      if (fuelBalance < 10000000000000000) {
        console.log(fuelBalance);
        console.log("Skipping Token ID:", tokenId, "(No Fuel)");
        continue;
      }

      if (targetState == State.ONLINE && state == State.ANCHORED) {
        console.log("Bringing Token ID Online:", tokenId);
        smartDeployable.bringOnline(smartObjectId);
        continue;
      }

      if (targetState == State.ANCHORED && state == State.ONLINE) {
        console.log("Bringing Token ID Offline:", tokenId);
        smartDeployable.bringOffline(smartObjectId);
        continue;
      }

      console.log("WARNING Token ID:", tokenId, " - Not Matched");
    }

    vm.stopBroadcast();
  }
}
