//
//  EQUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

///
/// Unit tests for **EQUnitPersistentState**.
///
class EQUnitPersistenceTests: AudioGraphTestCase {
    
    func testPersistence_10BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 1...(runLongRunningTests ? 1000 : 100) {
                
                let serializedState = EQUnitPersistentState(state: state,
                                                            userPresets: randomEQPresets(unitState: .active),
                                                            type: .tenBand, globalGain: randomEQGain(),
                                                            bands: randomEQ10Bands())
                
                doTestPersistence(serializedState: serializedState)
            }
        }
    }
    
    func testPersistence_15BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 1...(runLongRunningTests ? 1000 : 100) {
                
                let serializedState = EQUnitPersistentState(state: state,
                                                            userPresets: randomEQPresets(unitState: .active),
                                                            type: .fifteenBand, globalGain: randomEQGain(),
                                                            bands: randomEQ15Bands())
                
                doTestPersistence(serializedState: serializedState)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension EQUnitPersistentState: Equatable {
    
    static func == (lhs: EQUnitPersistentState, rhs: EQUnitPersistentState) -> Bool {
        
        lhs.state == rhs.state && lhs.userPresets == rhs.userPresets &&
            lhs.type == rhs.type &&
            [Float].approxEquals(lhs.bands, rhs.bands, accuracy: 0.001) &&
            Float.approxEquals(lhs.globalGain, rhs.globalGain, accuracy: 0.001)
    }
}

extension EQPresetPersistentState: Equatable {
    
    static func == (lhs: EQPresetPersistentState, rhs: EQPresetPersistentState) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            [Float].approxEquals(lhs.bands, rhs.bands, accuracy: 0.001) &&
            Float.approxEquals(lhs.globalGain, rhs.globalGain, accuracy: 0.001)
    }
}
