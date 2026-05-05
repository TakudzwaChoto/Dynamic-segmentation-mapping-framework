// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./WaterQualityData.sol";

contract OptimizedContract {
    using WaterQualityData for WaterQualityData.WaterQualityRecord;
    
    mapping(address => mapping(uint256 => WaterQualityData.WaterQualityRecord))
        public recentQualityEvents;
    mapping(address => uint256[]) public historicalTimestamps;
    mapping(address => mapping(uint256 => uint8)) public retentionScores;
    
    uint256 public constant THIRTY_DAYS = 30 * 24 * 3600;
    uint256 public constant RETENTION_SCORE_THRESHOLD = 70;
    
    address public owner;
    
    event QualityReported(
        address indexed user,
        uint256 indexed timestamp,
        uint8 ph,
        uint16 turbidity,
        uint8 dissolvedOxygen,
        uint8 temperature,
        bool contaminants,
        uint8 eColiLevel
    );
    event DataMigratedToHistorical(address indexed user, uint256 indexed timestamp);
    event DataMigratedToOffChain(address indexed user, uint256 indexed timestamp, bytes32 indexed offChainHash);
    event RetentionScoreUpdated(address indexed user, uint256 indexed timestamp, uint8 score);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
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
        require(dissolvedOxygen <= 20, "DO exceeds maximum");
        require(temperature <= 50, "Temperature exceeds maximum");
        require(eColiLevel <= 5, "E. coli level must be 0-5");
        
        uint256 timestamp = block.timestamp;
        
        WaterQualityData.WaterQualityRecord memory record = WaterQualityData.WaterQualityRecord({
            timestamp: timestamp,
            ph: ph,
            turbidity: turbidity,
            dissolvedOxygen: dissolvedOxygen,
            temperature: temperature,
            contaminantsDetected: contaminants,
            eColiLevel: eColiLevel
        });
        
        recentQualityEvents[user][timestamp] = record;
        historicalTimestamps[user].push(timestamp);
        
        emit QualityReported(user, timestamp, ph, turbidity, dissolvedOxygen, temperature, contaminants, eColiLevel);
    }
    
    function getRecentQualityRecords(address user)
        public
        view
        returns (uint256[] memory, WaterQualityData.WaterQualityRecord[] memory)
    {
        uint256[] storage timestamps = historicalTimestamps[user];
        WaterQualityData.WaterQualityRecord[] memory records = new WaterQualityData.WaterQualityRecord[](timestamps.length);
        
        for (uint256 i = 0; i < timestamps.length; i++) {
            records[i] = recentQualityEvents[user][timestamps[i]];
        }
        
        return (timestamps, records);
    }
    
    function getQualityRecord(address user, uint256 timestamp)
        public
        view
        returns (WaterQualityData.WaterQualityRecord memory)
    {
        return recentQualityEvents[user][timestamp];
    }
    
    function migrateToHistorical(address user, uint256 beforeTimestamp) public {
        uint256[] storage timestamps = historicalTimestamps[user];
        
        for (uint256 i = 0; i < timestamps.length; i++) {
            if (timestamps[i] < beforeTimestamp) {
                delete recentQualityEvents[user][timestamps[i]];
                emit DataMigratedToHistorical(user, timestamps[i]);
            }
        }
    }
    
    function migrateToOffChain(address user, uint256 beforeTimestamp) public {
        uint256[] storage timestamps = historicalTimestamps[user];
        
        for (uint256 i = 0; i < timestamps.length; i++) {
            if (timestamps[i] < beforeTimestamp) {
                WaterQualityData.WaterQualityRecord memory record = recentQualityEvents[user][timestamps[i]];
                bytes32 offChainHash = keccak256(abi.encodePacked(record.timestamp, record.ph, record.turbidity));
                delete recentQualityEvents[user][timestamps[i]];
                emit DataMigratedToOffChain(user, timestamps[i], offChainHash);
            }
        }
    }
    
    function copyRelevantData(address user) public {
        uint256[] storage timestamps = historicalTimestamps[user];
        
        for (uint256 i = 0; i < timestamps.length; i++) {
            if (block.timestamp - timestamps[i] < THIRTY_DAYS) {
                emit DataMigratedToHistorical(user, timestamps[i]);
            }
        }
    }
    
    function updateRetentionScore(address user, uint256 timestamp, uint8 score) public onlyOwner {
        require(score <= 100, "Score must be 0-100");
        retentionScores[user][timestamp] = score;
        emit RetentionScoreUpdated(user, timestamp, score);
    }
    
    function shouldKeepOnChain(address user, uint256 timestamp) public view returns (bool) {
        uint8 score = retentionScores[user][timestamp];
        bool recent = (block.timestamp - timestamp) < 7 days;
        bool hasContaminants = recentQualityEvents[user][timestamp].contaminantsDetected;
        return (score >= RETENTION_SCORE_THRESHOLD) || recent || hasContaminants;
    }
    
    function getRecordCount(address user) public view returns (uint256) {
        return historicalTimestamps[user].length;
    }
}
