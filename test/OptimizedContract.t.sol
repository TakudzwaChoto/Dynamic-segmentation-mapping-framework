// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/OptimizedContract.sol";
import "../contracts/UnoptimizedContract.sol";

contract OptimizedContractTest is Test {
    OptimizedContract public opt;
    UnoptimizedContract public unopt;
    address public user = address(0x1234);
    address public user2 = address(0x5678);
    
    function setUp() public {
        opt = new OptimizedContract();
        unopt = new UnoptimizedContract();
        vm.deal(user, 10 ether);
        vm.deal(user2, 10 ether);
    }
    
    function test_ReportQuality_Success() public {
        vm.prank(user);
        opt.reportQuality(user, 7, 50, 8, 20, false, 1);
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        assertEq(timestamps.length, 1);
    }
    
    function test_ReportQuality_MultipleRecords() public {
        vm.prank(user);
        for (uint i = 0; i < 10; i++) {
            opt.reportQuality(user, uint8(i), 50, 8, 20, false, 1);
        }
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        assertEq(timestamps.length, 10);
    }
    
    function test_ReportQuality_MultipleUsers() public {
        vm.prank(user);
        opt.reportQuality(user, 7, 50, 8, 20, false, 1);
        
        vm.prank(user2);
        opt.reportQuality(user2, 8, 30, 9, 22, false, 0);
        
        (uint256[] memory timestamps1, ) = opt.getRecentQualityRecords(user);
        (uint256[] memory timestamps2, ) = opt.getRecentQualityRecords(user2);
        
        assertEq(timestamps1.length, 1);
        assertEq(timestamps2.length, 1);
    }
    
    function test_GetRecentQualityRecords_Empty() public {
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        assertEq(timestamps.length, 0);
    }
    
    function test_MigrateToHistorical_Success() public {
        for (uint i = 0; i < 5; i++) {
            vm.prank(user);
            opt.reportQuality(user, 7, 50, 8, 20, false, 1);
        }
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        uint256 firstTimestamp = timestamps[0];
        
        vm.prank(user);
        opt.migrateToHistorical(user, firstTimestamp + 1);
        
        (timestamps, ) = opt.getRecentQualityRecords(user);
        assertEq(timestamps.length, 4);
    }
    
    function test_MigrateToOffChain_Success() public {
        for (uint i = 0; i < 5; i++) {
            vm.prank(user);
            opt.reportQuality(user, 7, 50, 8, 20, false, 1);
        }
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        uint256 firstTimestamp = timestamps[0];
        
        vm.prank(user);
        opt.migrateToOffChain(user, firstTimestamp + 1);
        
        (timestamps, ) = opt.getRecentQualityRecords(user);
        assertEq(timestamps.length, 4);
    }
    
    function test_OptimizedVsUnoptimized_GasComparison() public {
        uint256 optGasStart = gasleft();
        vm.prank(user);
        opt.reportQuality(user, 7, 50, 8, 20, false, 1);
        uint256 optGasUsed = optGasStart - gasleft();
        
        uint256 unoptGasStart = gasleft();
        vm.prank(user);
        unopt.reportQuality(user, 7, 50, 8, 20, false, 1);
        uint256 unoptGasUsed = unoptGasStart - gasleft();
        
        emit log_named_uint("Optimized gas (reportQuality)", optGasUsed);
        emit log_named_uint("Unoptimized gas (reportQuality)", unoptGasUsed);
        
        assertLt(optGasUsed, unoptGasUsed);
    }
    
    function test_PH_Boundary_Min() public {
        vm.prank(user);
        opt.reportQuality(user, 0, 50, 8, 20, false, 1);
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        WaterQualityData.WaterQualityRecord memory record = opt.getQualityRecord(user, timestamps[0]);
        assertEq(record.ph, 0);
    }
    
    function test_PH_Boundary_Max() public {
        vm.prank(user);
        opt.reportQuality(user, 14, 50, 8, 20, false, 1);
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        WaterQualityData.WaterQualityRecord memory record = opt.getQualityRecord(user, timestamps[0]);
        assertEq(record.ph, 14);
    }
    
    function test_InvalidPH_High() public {
        vm.prank(user);
        vm.expectRevert("pH must be 0-14");
        opt.reportQuality(user, 15, 50, 8, 20, false, 1);
    }
    
    function test_InvalidPH_Low() public {
        vm.prank(user);
        vm.expectRevert("pH must be 0-14");
        opt.reportQuality(user, 255, 50, 8, 20, false, 1);
    }
    
    function test_DataIntegrity_AfterStorage() public {
        vm.prank(user);
        opt.reportQuality(user, 7, 50, 8, 20, false, 1);
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        WaterQualityData.WaterQualityRecord memory record = opt.getQualityRecord(user, timestamps[0]);
        
        assertEq(record.ph, 7);
        assertEq(record.turbidity, 50);
        assertEq(record.dissolvedOxygen, 8);
        assertEq(record.temperature, 20);
        assertEq(record.contaminantsDetected, false);
        assertEq(record.eColiLevel, 1);
    }
    
    function test_RetentionScore_Update() public {
        vm.prank(user);
        opt.reportQuality(user, 7, 50, 8, 20, false, 1);
        
        (uint256[] memory timestamps, ) = opt.getRecentQualityRecords(user);
        
        vm.prank(opt.owner());
        opt.updateRetentionScore(user, timestamps[0], 85);
        
        bool shouldKeep = opt.shouldKeepOnChain(user, timestamps[0]);
        assertTrue(shouldKeep);
    }
}
