//
//  SystemUtils.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A collection of utilities that provide access to system-level information.
///
class SystemUtils {
    
    static var numberOfActiveCores: Int {
        ProcessInfo.processInfo.activeProcessorCount
    }
    
    static var numberOfPhysicalCores: Int {
        
        var cores: Int = 1
        sysctlbyname("hw.physicalcpu", nil, &cores, nil, 0)
        return max(cores, 1)
    }
    
    static var osVersion: OperatingSystemVersion {
        ProcessInfo.processInfo.operatingSystemVersion
    }
    
    static var openFilesLimit: UInt64 {
        
        get {
            
            var limit: rlimit = rlimit()
            getrlimit(RLIMIT_NOFILE, &limit);
            return limit.rlim_cur
        }
        
        set(newLimit) {
            
            var limit: rlimit = rlimit()
            
            getrlimit(RLIMIT_NOFILE, &limit);
            limit.rlim_cur = newLimit
            
            setrlimit(RLIMIT_NOFILE, &limit);
        }
    }
    
    static let primaryVolumeName: String? = {
        
        let url = URL(fileURLWithPath: "/Users")
        
        do {
            return try url.resourceValues(forKeys: [.volumeNameKey]).allValues[.volumeNameKey] as? String
        } catch {
            return nil
        }
    }()
    
    static var secondaryVolumes: [URL] {
        
        FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [URLResourceKey.volumeNameKey],
                                      options: [])?.filter{$0.path.hasPrefix("/Volumes")} ?? []
    }
}
