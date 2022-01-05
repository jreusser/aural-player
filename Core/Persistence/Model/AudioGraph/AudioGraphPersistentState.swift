//
//  AudioGraphPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the audio graph.
///
/// - SeeAlso:  `AudioGraph`
///
struct AudioGraphPersistentState: Codable {

#if os(macOS)
    let outputDevice: AudioDevicePersistentState?
#endif
    
    let volume: Float?
    let muted: Bool?
    let pan: Float?
    
    let masterUnit: MasterUnitPersistentState?
    let eqUnit: EQUnitPersistentState?
    let pitchUnit: PitchShiftUnitPersistentState?
    let timeUnit: TimeStretchUnitPersistentState?
    let reverbUnit: ReverbUnitPersistentState?
    let delayUnit: DelayUnitPersistentState?
    let filterUnit: FilterUnitPersistentState?
    let audioUnits: [AudioUnitPersistentState]?
    
    let soundProfiles: [SoundProfilePersistentState]?
}
