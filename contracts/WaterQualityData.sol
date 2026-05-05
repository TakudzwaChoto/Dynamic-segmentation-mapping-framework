// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library WaterQualityData {
    
    struct WaterQualityRecord {
        uint256 timestamp;
        uint8 ph;
        uint16 turbidity;
        uint8 dissolvedOxygen;
        uint8 temperature;
        bool contaminantsDetected;
        uint8 eColiLevel;
    }
    
    function calculateWQI(WaterQualityRecord memory record) internal pure returns (uint8) {
        uint256 totalScore = 0;
        uint256 weightSum = 0;
        
        if (record.ph >= 6 && record.ph <= 9) {
            totalScore += 20;
        } else if (record.ph >= 5 && record.ph <= 10) {
            totalScore += 10;
        }
        weightSum += 20;
        
        if (record.turbidity <= 5) totalScore += 20;
        else if (record.turbidity <= 10) totalScore += 15;
        else if (record.turbidity <= 20) totalScore += 10;
        else if (record.turbidity <= 50) totalScore += 5;
        weightSum += 20;
        
        if (record.dissolvedOxygen >= 8) totalScore += 20;
        else if (record.dissolvedOxygen >= 6) totalScore += 15;
        else if (record.dissolvedOxygen >= 4) totalScore += 10;
        weightSum += 20;
        
        if (!record.contaminantsDetected) totalScore += 20;
        weightSum += 20;
        
        if (record.eColiLevel == 0) totalScore += 20;
        else if (record.eColiLevel <= 2) totalScore += 10;
        weightSum += 20;
        
        return uint8((totalScore * 100) / weightSum);
    }
}
