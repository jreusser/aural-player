//
//  AudioDeviceList.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
#if os(macOS)

import AVFoundation

///
/// Encapsulates a collection of audio output hardware devices available on the local system, and provides
/// functions for convenient searching of devices.
///
/// This class is for external use by clients of **DeviceManager**.
///
class AudioDeviceList {
    
    static let unknown: AudioDeviceList = AudioDeviceList(allDevices: [], outputDeviceId: kAudioObjectUnknown, systemDeviceId: kAudioObjectUnknown)
    
    let allDevices: [AudioDevice]
    
    var numberOfDevices: Int {allDevices.count}
    
    let systemDevice: AudioDevice
    let outputDevice: AudioDevice
    let indexOfOutputDevice: Int
    
    init(allDevices: [AudioDevice], outputDeviceId: AudioDeviceID, systemDeviceId: AudioDeviceID) {
        
        self.allDevices = allDevices
        
        let systemDevice = allDevices.first(where: {$0.id == systemDeviceId})!
        self.systemDevice = systemDevice
        
        self.outputDevice = allDevices.first(where: {$0.id == outputDeviceId}) ?? systemDevice
        self.indexOfOutputDevice = allDevices.firstIndex(of: outputDevice) ?? 0
    }
    
    func find(byName name: String, andUID uid: String) -> AudioDevice? {
        allDevices.first(where: {$0.name == name && $0.uid == uid})
    }
    
    func find(byUID uid: String) -> AudioDevice? {
        allDevices.first(where: {$0.uid == uid})
    }
}

#endif
