//
//  EQUnitTests.swift
//  Tests
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class EQUnitTests: AudioGraphTestCase {
    
    func testInit_10BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = EQUnitPersistentState(state: state,
                                                            userPresets: randomEQPresets(unitState: .active),
                                                            type: .tenBand, globalGain: randomEQGain(),
                                                            bands: randomEQ10Bands())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    func testInit_15BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = EQUnitPersistentState(state: state,
                                                            userPresets: randomEQPresets(unitState: .active),
                                                            type: .fifteenBand, globalGain: randomEQGain(),
                                                            bands: randomEQ15Bands())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    // TODO: Test with invalid / missing values in persistent state.
    
    private func doTestInit(persistentState: EQUnitPersistentState) {
        
        let eqUnit = EQUnit(persistentState: persistentState)
        validate(eqUnit, persistentState: persistentState)
    }
    
    func testToggleState() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = EQUnitPersistentState(state: startingState, userPresets: nil, type: .randomCase(),
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            
            XCTAssertEqual(eqUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = eqUnit.state == .active ? .bypassed : .active
                let newState = eqUnit.toggleState()
                
                XCTAssertEqual(eqUnit.state, expectedState)
                XCTAssertEqual(newState, expectedState)
                
                XCTAssertEqual(eqUnit.node.bypass, eqUnit.state != .active)
                XCTAssertEqual(eqUnit.node.activeNode.bypass, eqUnit.state != .active)
            }
        }
    }
    
    func testIsActive() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = EQUnitPersistentState(state: startingState, userPresets: nil, type: .randomCase(),
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            
            XCTAssertEqual(eqUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = eqUnit.state == .active ? .bypassed : .active
                _ = eqUnit.toggleState()
                
                XCTAssertEqual(eqUnit.state, expectedState)
                XCTAssertEqual(eqUnit.isActive, expectedState == .active)
                
                XCTAssertEqual(eqUnit.node.bypass, !eqUnit.isActive)
                XCTAssertEqual(eqUnit.node.activeNode.bypass, !eqUnit.isActive)
            }
        }
    }
    
    func testSuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = EQUnitPersistentState(state: startingState, userPresets: nil, type: .randomCase(),
                                                            globalGain: nil, bands: nil)
                
                let eqUnit = EQUnit(persistentState: persistentState)
                
                XCTAssertEqual(eqUnit.state, startingState)
                
                let expectedState: EffectsUnitState = eqUnit.state == .active ? .suppressed : eqUnit.state
                eqUnit.suppress()
                
                XCTAssertEqual(eqUnit.state, expectedState)
                XCTAssertEqual(eqUnit.isActive, expectedState == .active)
                
                if eqUnit.state == .suppressed {
                    
                    XCTAssertTrue(eqUnit.node.bypass)
                    XCTAssertTrue(eqUnit.node.activeNode.bypass)
                }
            }
        }
    }
    
    func testUnsuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = EQUnitPersistentState(state: startingState, userPresets: nil, type: .randomCase(),
                                                            globalGain: nil, bands: nil)
                
                let eqUnit = EQUnit(persistentState: persistentState)
                
                XCTAssertEqual(eqUnit.state, startingState)
                
                let expectedState: EffectsUnitState = eqUnit.state == .suppressed ? .active : eqUnit.state
                eqUnit.unsuppress()
                
                XCTAssertEqual(eqUnit.state, expectedState)
                XCTAssertEqual(eqUnit.isActive, expectedState == .active)
                
                if eqUnit.state == .active {
                    
                    XCTAssertFalse(eqUnit.node.bypass)
                    XCTAssertFalse(eqUnit.node.activeNode.bypass)
                }
            }
        }
    }
    
    func testSavePreset() {
        
        for _ in 1...1000 {
            
            let persistentState = EQUnitPersistentState(state: .active, userPresets: nil, type: .randomCase(),
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            XCTAssertEqual(eqUnit.state, .active)
            
            let eqType = EQType.randomCase()
            
            eqUnit.type = eqType
            eqUnit.bands = randomEQBands(forType: eqType)
            eqUnit.globalGain = randomEQGain()
            
            let presetName = "TestEQPreset-1"
            eqUnit.savePreset(named: presetName)
            
            guard let savedPreset = eqUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save EQ preset named \(presetName)")
                continue
            }
            
            XCTAssertEqual(savedPreset.name, presetName)
            XCTAssertEqual(savedPreset.globalGain, eqUnit.globalGain, accuracy: 0.001)
            AssertEqual(savedPreset.bands, eqUnit.bands, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = EQUnitPersistentState(state: .active, userPresets: nil, type: .randomCase(),
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            XCTAssertEqual(eqUnit.state, .active)
            
            let eqType = EQType.randomCase()
            
            eqUnit.type = eqType
            eqUnit.bands = randomEQBands(forType: eqType)
            eqUnit.globalGain = randomEQGain()
            
            let presetName = "TestEQPreset-1"
            eqUnit.savePreset(named: presetName)
            
            guard let savedPreset = eqUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save EQ preset named \(presetName)")
                continue
            }
            
            eqUnit.globalGain = randomEQGain()
            eqUnit.bands = randomEQBands(forType: eqType)
            
            XCTAssertNotEqual(eqUnit.globalGain, savedPreset.globalGain)
            AssertNotEqual(eqUnit.bands, savedPreset.bands)
            
            eqUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(eqUnit.globalGain, savedPreset.globalGain, accuracy: 0.001)
            AssertEqual(eqUnit.bands, savedPreset.bands, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let eqType = EQType.randomCase()
            let persistentPresets = randomEQPresets(type: eqType, count: 3, unitState: .active)
            
            let persistentState = EQUnitPersistentState(state: .active, userPresets: persistentPresets, type: eqType,
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            XCTAssertEqual(eqUnit.state, .active)
            XCTAssertEqual(eqUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            eqUnit.bands = randomEQBands(forType: eqType)
            eqUnit.globalGain = randomEQGain()
            
            let presetToApply = eqUnit.presets.userDefinedPresets.randomElement()
            let presetName = presetToApply.name
            
            XCTAssertNotEqual(eqUnit.globalGain, presetToApply.globalGain)
            AssertNotEqual(eqUnit.bands, presetToApply.bands)
            
            eqUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(eqUnit.globalGain, presetToApply.globalGain, accuracy: 0.001)
            AssertEqual(eqUnit.bands, presetToApply.bands, accuracy: 0.001)
        }
    }
    
    func testApplyPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = EQUnitPersistentState(state: .active, userPresets: nil, type: .randomCase(),
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            XCTAssertEqual(eqUnit.state, .active)
            
            let eqType = EQType.randomCase()
            
            eqUnit.type = eqType
            eqUnit.bands = randomEQBands(forType: eqType)
            eqUnit.globalGain = randomEQGain()
            
            let presetName = "TestEQPreset-1"
            eqUnit.savePreset(named: presetName)
            
            guard let savedPreset = eqUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save EQ preset named \(presetName)")
                continue
            }
            
            eqUnit.globalGain = randomEQGain()
            eqUnit.bands = randomEQBands(forType: eqType)
            
            XCTAssertNotEqual(eqUnit.globalGain, savedPreset.globalGain)
            AssertNotEqual(eqUnit.bands, savedPreset.bands)
            
            eqUnit.applyPreset(savedPreset)
            
            XCTAssertEqual(eqUnit.globalGain, savedPreset.globalGain, accuracy: 0.001)
            AssertEqual(eqUnit.bands, savedPreset.bands, accuracy: 0.001)
        }
    }
    
    func testApplyPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let eqType = EQType.randomCase()
            let persistentPresets = randomEQPresets(type: eqType, count: 3, unitState: .active)
            
            let persistentState = EQUnitPersistentState(state: .active, userPresets: persistentPresets, type: eqType,
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            XCTAssertEqual(eqUnit.state, .active)
            XCTAssertEqual(eqUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            eqUnit.bands = randomEQBands(forType: eqType)
            eqUnit.globalGain = randomEQGain()
            
            let presetToApply = eqUnit.presets.userDefinedPresets.randomElement()
            
            XCTAssertNotEqual(eqUnit.globalGain, presetToApply.globalGain)
            AssertNotEqual(eqUnit.bands, presetToApply.bands)
            
            eqUnit.applyPreset(presetToApply)
            
            XCTAssertEqual(eqUnit.globalGain, presetToApply.globalGain, accuracy: 0.001)
            AssertEqual(eqUnit.bands, presetToApply.bands, accuracy: 0.001)
        }
    }
    
    func testSettingsAsPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = EQUnitPersistentState(state: .active, userPresets: nil, type: .randomCase(),
                                                        globalGain: nil, bands: nil)
            
            let eqUnit = EQUnit(persistentState: persistentState)
            XCTAssertEqual(eqUnit.state, .active)
            
            let eqType = EQType.randomCase()
            
            eqUnit.type = eqType
            eqUnit.bands = randomEQBands(forType: eqType)
            eqUnit.globalGain = randomEQGain()
            
            let settingsAsPreset: EQPreset = eqUnit.settingsAsPreset
            
            XCTAssertEqual(settingsAsPreset.globalGain, eqUnit.globalGain, accuracy: 0.001)
            AssertEqual(settingsAsPreset.bands, eqUnit.bands, accuracy: 0.001)
        }
    }
    
    func testType() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let type: EQType = .randomCase()
            eqUnit.type = type
            
            XCTAssertEqual(eqUnit.type, type)
            XCTAssertEqual(eqUnit.node.type, type)
            
            if type == .tenBand {
                
                XCTAssertEqual(eqUnit.bands.count, 10)
                XCTAssertEqual(eqUnit.node.bands.count, 10)
                XCTAssertEqual(eqUnit.node.activeNode.bands.count, 10)
                
                XCTAssertEqual(eqUnit.node.activeNode, eqUnit.node.eq10Node)
                AssertEqual(eqUnit.node.bands, eqUnit.node.eq10Node.bandGains, accuracy: 0.001)
                AssertEqual(eqUnit.bands, eqUnit.node.eq10Node.bandGains, accuracy: 0.001)
                
            } else {
                
                XCTAssertEqual(eqUnit.bands.count, 15)
                XCTAssertEqual(eqUnit.node.bands.count, 15)
                XCTAssertEqual(eqUnit.node.activeNode.bands.count, 15)
                
                XCTAssertEqual(eqUnit.node.activeNode, eqUnit.node.eq15Node)
                AssertEqual(eqUnit.node.bands, eqUnit.node.eq15Node.bandGains, accuracy: 0.001)
                AssertEqual(eqUnit.bands, eqUnit.node.eq15Node.bandGains, accuracy: 0.001)
            }
        }
    }
    
    private let minGain = ParametricEQNode.validGainRange.lowerBound
    private let maxGain = ParametricEQNode.validGainRange.upperBound
    
    func testGlobalGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let gain = randomEQGain()
            doTestGlobalGain(gain, withUnit: eqUnit)
        }
        
        // Special values
        for gain in [0, minGain, maxGain] {
            doTestGlobalGain(gain, withUnit: eqUnit)
        }
    }
    
    private func doTestGlobalGain(_ gain: Float, withUnit eqUnit: EQUnit) {
        
        eqUnit.globalGain = gain
        
        XCTAssertEqual(eqUnit.globalGain, gain, accuracy: 0.001)
        XCTAssertEqual(eqUnit.node.globalGain, gain, accuracy: 0.001)
        XCTAssertEqual(eqUnit.node.activeNode.globalGain, gain, accuracy: 0.001)
    }
    
    func testBands_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        for _ in 1...1000 {
            
            let bands: [Float] = randomEQ10Bands()
            doTestBands(bands, withUnit: eqUnit)
        }
        
        // Special values
        doTestBands(Array(repeating: 0, count: 10), withUnit: eqUnit)
        doTestBands(Array(repeating: minGain, count: 10), withUnit: eqUnit)
        doTestBands(Array(repeating: maxGain, count: 10), withUnit: eqUnit)
    }
    
    func testBands_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        for _ in 1...1000 {
            
            let bands: [Float] = randomEQ15Bands()
            doTestBands(bands, withUnit: eqUnit)
        }
        
        // Special values
        doTestBands(Array(repeating: 0, count: 15), withUnit: eqUnit)
        doTestBands(Array(repeating: minGain, count: 15), withUnit: eqUnit)
        doTestBands(Array(repeating: maxGain, count: 15), withUnit: eqUnit)
    }
    
    private func doTestBands(_ bands: [Float], withUnit eqUnit: EQUnit) {
        
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        AssertEqual(eqUnit.node.bands, bands, accuracy: 0.001)
        AssertEqual(eqUnit.node.activeNode.bandGains, bands, accuracy: 0.001)
        
        if bands.count == 10 {
            AssertEqual(eqUnit.node.eq10Node.bandGains, bands, accuracy: 0.001)
        } else {
            AssertEqual(eqUnit.node.eq15Node.bandGains, bands, accuracy: 0.001)
        }
    }
    
    func testSubscript_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        for _ in 1...1000 {
            
            let bands: [Float] = randomEQ10Bands()
            doTestSubscript(bands, type: .tenBand, withUnit: eqUnit)
        }
    }
    
    private func doTestSubscript(_ bands: [Float], type: EQType, withUnit eqUnit: EQUnit) {
        
        for index in 0..<(type == .tenBand ? 10 : 15) {
            
            eqUnit[index] = bands[index]
            
            XCTAssertEqual(eqUnit[index], bands[index], accuracy: 0.001)
            XCTAssertEqual(eqUnit.bands[index], bands[index], accuracy: 0.001)
            
            XCTAssertEqual(eqUnit.node.activeNode.bandGains[index], bands[index], accuracy: 0.001)
            
            if type == .tenBand {
                XCTAssertEqual(eqUnit.node.eq10Node.bandGains[index], bands[index], accuracy: 0.001)
            } else {
                XCTAssertEqual(eqUnit.node.eq15Node.bandGains[index], bands[index], accuracy: 0.001)
            }
        }
    }
    
    func testSubscript_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        for _ in 1...1000 {
            
            let bands: [Float] = randomEQ15Bands()
            doTestSubscript(bands, type: .fifteenBand, withUnit: eqUnit)
        }
    }
    
    func testIncreaseBass_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.increaseBass(by:), deltaMultiplier: 1,
                                          eqType: .tenBand, changedBands: Array(0...2), unchangedBands: Array(3..<10))
    }
    
    func testIncreaseBass_10Bands_alreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands = Array(repeating: maxGain, count: 10)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseBass(by: increment)
        
            // Verify that the bands are unchaged by the increaseBass() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterIncrease, bands, accuracy: 0.001)
        }
    }
    
    func testIncreaseBass_10Bands_someBandsAlreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands: [Float] = [randomEQGain(), maxGain, randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeIncrease = eqUnit.bands
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseBass(by: increment)
        
            let expectedBands = bandsBeforeIncrease.enumerated().map {(index, gain) -> Float in
                
                if index < 3 {
                    return (gain + increment).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 0...2 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterIncrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testIncreaseBass_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.increaseBass(by:), deltaMultiplier: 1,
                                          eqType: .fifteenBand, changedBands: Array(0...4), unchangedBands: Array(5..<15))
    }
    
    func testIncreaseBass_15Bands_alreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands = Array(repeating: maxGain, count: 15)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseBass(by: increment)
        
            // Verify that the bands are unchaged by the increaseBass() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterIncrease, bands, accuracy: 0.001)
        }
    }
    
    func testIncreaseBass_15Bands_someBandsAlreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands: [Float] = [randomEQGain(), maxGain, randomEQGain(), maxGain, randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeIncrease = eqUnit.bands
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseBass(by: increment)
        
            let expectedBands = bandsBeforeIncrease.enumerated().map {(index, gain) -> Float in
                
                if index < 5 {
                    return (gain + increment).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 0...4 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterIncrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testIncreaseMids_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.increaseMids(by:), deltaMultiplier: 1,
                                          eqType: .tenBand, changedBands: Array(3...6), unchangedBands: Array(0...2) + Array(7..<10))
    }
    
    func testIncreaseMids_10Bands_alreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands = Array(repeating: maxGain, count: 10)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseMids(by: increment)
        
            // Verify that the bands are unchaged by the increaseMids() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterIncrease, bands, accuracy: 0.001)
        }
    }
    
    func testIncreaseMids_10Bands_someBandsAlreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), maxGain, randomEQGain(),
                              randomEQGain(), maxGain, randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeIncrease = eqUnit.bands
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseMids(by: increment)
        
            let expectedBands = bandsBeforeIncrease.enumerated().map {(index, gain) -> Float in
                
                if (3...6).contains(index) {
                    return (gain + increment).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 3...6 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterIncrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testIncreaseMids_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.increaseMids(by:), deltaMultiplier: 1,
                                          eqType: .fifteenBand, changedBands: Array(5...10), unchangedBands: Array(0...4) + Array(11..<15))
    }
    
    func testIncreaseMids_15Bands_alreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands = Array(repeating: maxGain, count: 15)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseMids(by: increment)
        
            // Verify that the bands are unchaged by the increaseMids() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterIncrease, bands, accuracy: 0.001)
        }
    }
    
    func testIncreaseMids_15Bands_someBandsAlreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              maxGain, maxGain, randomEQGain(), maxGain, randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeIncrease = eqUnit.bands
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseMids(by: increment)
        
            let expectedBands = bandsBeforeIncrease.enumerated().map {(index, gain) -> Float in
                
                if (5...10).contains(index) {
                    return (gain + increment).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 5...10 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterIncrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testIncreaseTreble_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.increaseTreble(by:), deltaMultiplier: 1,
                                          eqType: .tenBand, changedBands: Array(7..<10), unchangedBands: Array(0...6))
    }
    
    func testIncreaseTreble_10Bands_alreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands = Array(repeating: maxGain, count: 10)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseTreble(by: increment)
        
            // Verify that the bands are unchaged by the increaseTreble() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterIncrease, bands, accuracy: 0.001)
        }
    }
    
    func testIncreaseTreble_10Bands_someBandsAlreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), maxGain, randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeIncrease = eqUnit.bands
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseTreble(by: increment)
        
            let expectedBands = bandsBeforeIncrease.enumerated().map {(index, gain) -> Float in
                
                if (7...9).contains(index) {
                    return (gain + increment).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 7...9 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterIncrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testIncreaseTreble_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.increaseTreble(by:), deltaMultiplier: 1,
                                          eqType: .fifteenBand, changedBands: Array(11..<15), unchangedBands: Array(0...10))
    }
    
    func testIncreaseTreble_15Bands_alreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands = Array(repeating: maxGain, count: 15)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseTreble(by: increment)
        
            // Verify that the bands are unchaged by the increaseTreble() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterIncrease, bands, accuracy: 0.001)
        }
    }
    
    func testIncreaseTreble_15Bands_someBandsAlreadyAtMaxGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), maxGain, randomEQGain(), maxGain]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeIncrease = eqUnit.bands
            let increment = Float.random(in: 0.1...5)
            let bandsAfterIncrease = eqUnit.increaseTreble(by: increment)
        
            let expectedBands = bandsBeforeIncrease.enumerated().map {(index, gain) -> Float in
                
                if (11...14).contains(index) {
                    return (gain + increment).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 11...14 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterIncrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testDecreaseBass_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.decreaseBass(by:), deltaMultiplier: -1,
                                          eqType: .tenBand, changedBands: Array(0...2), unchangedBands: Array(3..<10))
    }
    
    func testDecreaseBass_10Bands_alreadyAtMinBass() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands = Array(repeating: minGain, count: 10)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseBass(by: decrement)
        
            // Verify that the bands are unchaged by the decreaseBass() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterDecrease, bands, accuracy: 0.001)
        }
    }
    
    func testDecreaseBass_10Bands_someBandsAlreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands: [Float] = [randomEQGain(), minGain, randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeDecrease = eqUnit.bands
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseBass(by: decrement)
        
            let expectedBands = bandsBeforeDecrease.enumerated().map {(index, gain) -> Float in
                
                if index < 3 {
                    return (gain - decrement).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 0...2 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterDecrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testDecreaseBass_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.decreaseBass(by:), deltaMultiplier: -1,
                                          eqType: .fifteenBand, changedBands: Array(0...4), unchangedBands: Array(5..<15))
    }
    
    func testDecreaseBass_15Bands_alreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands = Array(repeating: minGain, count: 15)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseBass(by: decrement)
        
            // Verify that the bands are unchaged by the decreaseBass() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterDecrease, bands, accuracy: 0.001)
        }
    }
    
    func testDecreaseBass_15Bands_someBandsAlreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands: [Float] = [randomEQGain(), minGain, randomEQGain(), minGain, randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeDecrease = eqUnit.bands
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseBass(by: decrement)
        
            let expectedBands = bandsBeforeDecrease.enumerated().map {(index, gain) -> Float in
                
                if index < 5 {
                    return (gain - decrement).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 0...4 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterDecrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testDecreaseMids_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.decreaseMids(by:), deltaMultiplier: -1,
                                          eqType: .tenBand, changedBands: Array(3...6), unchangedBands: Array(0...2) + Array(7..<10))
    }
    
    func testDecreaseMids_10Bands_alreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands = Array(repeating: minGain, count: 10)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseMids(by: decrement)
        
            // Verify that the bands are unchaged by the decreaseMids() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterDecrease, bands, accuracy: 0.001)
        }
    }
    
    func testDecreaseMids_10Bands_someBandsAlreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), minGain, randomEQGain(),
                              randomEQGain(), minGain, randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeDecrease = eqUnit.bands
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseMids(by: decrement)
        
            let expectedBands = bandsBeforeDecrease.enumerated().map {(index, gain) -> Float in
                
                if (3...6).contains(index) {
                    return (gain - decrement).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 3...6 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterDecrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testDecreaseMids_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.decreaseMids(by:), deltaMultiplier: -1,
                                          eqType: .fifteenBand, changedBands: Array(5...10), unchangedBands: Array(0...4) + Array(11..<15))
    }
    
    func testDecreaseMids_15Bands_alreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands = Array(repeating: minGain, count: 15)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseMids(by: decrement)
        
            // Verify that the bands are unchaged by the decreaseMids() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterDecrease, bands, accuracy: 0.001)
        }
    }
    
    func testDecreaseMids_15Bands_someBandsAlreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), minGain, randomEQGain(), minGain, randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeDecrease = eqUnit.bands
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseMids(by: decrement)
        
            let expectedBands = bandsBeforeDecrease.enumerated().map {(index, gain) -> Float in
                
                if (5...10).contains(index) {
                    return (gain - decrement).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 5...10 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterDecrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testDecreaseTreble_10Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.decreaseTreble(by:), deltaMultiplier: -1,
                                          eqType: .tenBand, changedBands: Array(7..<10), unchangedBands: Array(0...6))
    }
    
    func testDecreaseTreble_10Bands_alreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands = Array(repeating: minGain, count: 10)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseTreble(by: decrement)
        
            // Verify that the bands are unchaged by the decreaseTreble() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterDecrease, bands, accuracy: 0.001)
        }
    }
    
    func testDecreaseTreble_10Bands_someBandsAlreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .tenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), maxGain, randomEQGain()]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeDecrease = eqUnit.bands
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseTreble(by: decrement)
        
            let expectedBands = bandsBeforeDecrease.enumerated().map {(index, gain) -> Float in
                
                if (7...9).contains(index) {
                    return (gain - decrement).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 7...9 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterDecrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    func testDecreaseTreble_15Bands() {
        
        let eqUnit = EQUnit(persistentState: nil)
        
        doTestIncreaseOrDecreaseBandGains(eqUnit: eqUnit, testFunction: eqUnit.decreaseTreble(by:), deltaMultiplier: -1,
                                          eqType: .fifteenBand, changedBands: Array(11..<15), unchangedBands: Array(0...10))
    }
    
    func testDecreaseTreble_15Bands_alreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands = Array(repeating: minGain, count: 15)
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseTreble(by: decrement)
        
            // Verify that the bands are unchaged by the decreaseTreble() call.
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
            AssertEqual(bandsAfterDecrease, bands, accuracy: 0.001)
        }
    }
    
    func testDecreaseTreble_15Bands_someBandsAlreadyAtMinGain() {
        
        let eqUnit = EQUnit(persistentState: nil)
        eqUnit.type = .fifteenBand
        
        let bands: [Float] = [randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(), randomEQGain(),
                              randomEQGain(), randomEQGain(), minGain, randomEQGain(), minGain]
        eqUnit.bands = bands
        
        AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
        for _ in 1...100 {
            
            let bandsBeforeDecrease = eqUnit.bands
            let decrement = Float.random(in: 0.1...5)
            let bandsAfterDecrease = eqUnit.decreaseTreble(by: decrement)
        
            let expectedBands = bandsBeforeDecrease.enumerated().map {(index, gain) -> Float in
                
                if (11...14).contains(index) {
                    return (gain - decrement).clamped(to: ParametricEQNode.validGainRange)
                }
                
                return gain
            }
            
            for index in 11...14 {
                
                XCTAssertEqual(eqUnit.bands[index], expectedBands[index], accuracy: 0.001)
                XCTAssertEqual(bandsAfterDecrease[index], expectedBands[index], accuracy: 0.001)
            }
        }
    }
    
    ///
    /// - Parameter deltaMultiplier:    +1 if intended as an increment, -1 if intended as a decrement.
    ///
    private func doTestIncreaseOrDecreaseBandGains(eqUnit: EQUnit, testFunction: @escaping (Float) -> [Float], deltaMultiplier: Float,
                                                   eqType: EQType, changedBands: [Int], unchangedBands: [Int]) {
        
        eqUnit.type = eqType
        
        for _ in 1...1000 {
            
            let bands: [Float] = randomEQBands(forType: eqType)
            eqUnit.bands = bands
            AssertEqual(eqUnit.bands, bands, accuracy: 0.001)
        
            // Delta is the increment / decrement.
            let delta = Float.random(in: 0.1...5)
            let bandsAfterTestFunctionCall = testFunction(delta)
            
            let activeEQNode = eqType == .tenBand ? eqUnit.node.eq10Node : eqUnit.node.eq15Node
        
            // Verify that the bands that should have changed did change.
            for index in changedBands {
                
                let expectedGain = (bands[index] + (delta * deltaMultiplier)).clamped(to: ParametricEQNode.validGainRange)
                
                XCTAssertEqual(eqUnit[index], expectedGain, accuracy: 0.001)
                XCTAssertEqual(eqUnit.bands[index], expectedGain, accuracy: 0.001)
                
                XCTAssertEqual(eqUnit.node.activeNode.bandGains[index], expectedGain, accuracy: 0.001)
                XCTAssertEqual(activeEQNode.bandGains[index], expectedGain, accuracy: 0.001)
                
                XCTAssertEqual(bandsAfterTestFunctionCall[index], expectedGain, accuracy: 0.001)
            }
            
            // Verify that the other bands are unchanged.
            for index in unchangedBands {
                
                XCTAssertEqual(eqUnit[index], bands[index], accuracy: 0.001)
                XCTAssertEqual(eqUnit.bands[index], bands[index], accuracy: 0.001)
                
                XCTAssertEqual(eqUnit.node.activeNode.bandGains[index], bands[index], accuracy: 0.001)
                XCTAssertEqual(activeEQNode.bandGains[index], bands[index], accuracy: 0.001)
                
                XCTAssertEqual(bandsAfterTestFunctionCall[index], bands[index], accuracy: 0.001)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension EQPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: EQPreset, rhs: EQPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            [Float].approxEquals(lhs.bands, rhs.bands, accuracy: 0.001) &&
            Float.approxEquals(lhs.globalGain, rhs.globalGain, accuracy: 0.001)
    }
}
