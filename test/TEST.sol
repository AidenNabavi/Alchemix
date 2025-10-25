// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/AlchemistAllocator.sol";


// Mock adapter contract needed as input for allocate and deallocate functions
contract MockAdapter {
    function adapterId() external pure returns (bytes32) {
        return bytes32(uint256(1)); // just a dummy ID
    }
}


// Mock Vault contract for simulation
contract MockVault {
    address public assetAddr = address(0xDEAD);

    function asset() external view returns (address) {
        return assetAddr;
    }

    // Other functions for simulation
    function absoluteCap(bytes32) external pure returns (uint256) { return 1000; }
    function relativeCap(bytes32) external pure returns (uint256) { return 1000; }
    function allocation(bytes32) external pure returns (uint256) { return 0; }
    function allocate(address, bytes memory, uint256) external pure {}
    function deallocate(address, bytes memory, uint256) external pure {}
}



// Test contract for allocate and deallocate functions
contract AlchemistCuratorPoC is Test {
    AlchemistAllocator alchemistallocator;
    MockVault vault;
    MockAdapter adapter;
    address admin = address(0x001);
    address operator = address(0x002);

    function setUp() public {
        vault = new MockVault();
        alchemistallocator = new AlchemistAllocator(address(vault), admin, operator);
        adapter = new MockAdapter();
    }

    // This test demonstrates that the allocate and deallocate functions
    // can be called with any amount of funds.
    // It also shows that operators can allocate or deallocate funds
    // to strategies without any enforced limit.
    function testOperatorCanAllocateDeallocateWithoutLimit() public {

        uint256 cap_amount = 1000; // hypothetical allowed amount for operators

        vm.startPrank(operator); // simulate calls from operator

        // for allocate() function
        // Because daoTarget = uint256.max, no limit is enforced:
        // This very large allocation executes without revert.
        alchemistallocator.allocate(address(adapter), 10000000000000000000 ether);
        //again with diffrente value
        alchemistallocator.allocate(address(adapter), cap_amount + 1);



        // Similarly for deallocate() function 
        alchemistallocator.deallocate(address(adapter), 100000000000000000 ether);
        //again with diffrente value
        alchemistallocator.deallocate(address(adapter), cap_amount + 10);
        vm.stopPrank();
        console.log("This means The operator can send any arbitrary amount, even far exceeding the absoluteCap.");
    }
}
