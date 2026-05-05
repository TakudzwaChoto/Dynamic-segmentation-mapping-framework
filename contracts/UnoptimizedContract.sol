// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UnoptimizedContract {
    struct QualityEvent {
        uint256 timestamp;
        uint8 ph;
        uint16 turbidity;
        uint8 dissolvedOxygen;
        uint8 temperature;
        bool contaminants;
        uint8 eColiLevel;
    }
    
    mapping(address => QualityEvent[]) public recentQualityRecords;
    mapping(address => QualityEvent[]) public historicalQualityData;
    
    event QualityReported(address indexed user, uint256 timestamp);
    
    function reportQuality(
        address user,
        uint8 ph,
        uint16 turbidity,
        uint8 dissolvedOxygen,
        uint8 temperature,
        bool contaminants,
        uint8 eColiLevel
    ) public {
        require(ph <= 14, "pH must be 0-14");
        require(turbidity <= 5000, "Turbidity exceeds maximum");
        
        uint256 timestamp = block.timestamp;
        
        QualityEvent memory event_ = QualityEvent({
            timestamp: timestamp,
            ph: ph,
            turbidity: turbidity,
            dissolvedOxygen: dissolvedOxygen,
            temperature: temperature,
            contaminants: contaminants,
            eColiLevel: eColiLevel
        });
        
        recentQualityRecords[user].push(event_);
        emit QualityReported(user, timestamp);
    }
    
    function getRecentQualityRecords(address user)
        public
        view
        returns (QualityEvent[] memory)
    {
        return recentQualityRecords[user];
    }
    
    function migrateToHistorical(address user, uint256 beforeTimestamp) public {
        QualityEvent[] storage recentEvents = recentQualityRecords[user];
        
        for (uint256 i = 0; i < recentEvents.length; i++) {
            if (recentEvents[i].timestamp < beforeTimestamp) {
                historicalQualityData[user].push(recentEvents[i]);
                _removeEvent(recentEvents, i);
                i--;
            }
        }
    }
    
    function _removeEvent(QualityEvent[] storage events, uint256 index) internal {
        require(index < events.length, "Index out of bounds");
        for (uint256 i = index; i < events.length - 1; i++) {
            events[i] = events[i + 1];
        }
        events.pop();
    }
}
