//
//  AppDelegate.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 06/01/22.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let userDocumentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let userDocumentsDirectory: URL = URL(fileURLWithPath: "/var/mobile/Music")
    lazy var file = userDocumentsDirectory.appendingPathComponent("Here.mp3")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        playQueueDelegate.loadTracks(from: userDocumentsDirectory.children ?? [], autoplay: false)
//        fftest()
        
        return true
    }
    
//    func fftest() {
//
//        let file: URL = userDocumentsDirectory.appendingPathComponent("PerfectWorld.wma")
//
//        print("\nTHE FILE IS: \(file.path)\n")
//
//        var pointer: UnsafeMutablePointer<AVFormatContext>! = avformat_alloc_context()
//
//        // Try to open the audio file so that it can be read.
//        var resultCode: Int32 = avformat_open_input(&pointer, file.path, nil, nil)
//
//        print("\nResult: \(resultCode)\n")
//
////        // MARK: Read the streams ----------------------------------------------------------------------------------
////
////        // Try to read information about the streams contained in this file.
//        resultCode = avformat_find_stream_info(pointer, nil)
//
//        guard let avStreamsArrayPointer = pointer.pointee.streams else {
//            print("\nERROR")
//            return
//        }
//
//        print("\nHERE Result: \(resultCode)\n")
//
//        self.avStreamPointers = (0..<pointer.pointee.nb_streams).compactMap {avStreamsArrayPointer.advanced(by: Int($0)).pointee}
//
//        let streamIndex = av_find_best_stream(pointer, AVMEDIA_TYPE_AUDIO, -1, -1, nil, 0)
//        let audioStream = avStreamPointers[Int(streamIndex)]
//
//        let duration = Double(audioStream.pointee.duration) * audioStream.pointee.time_base.ratio
//        print("\nDuration of the file is: \(duration)")
//
//        let avContext = pointer.pointee
//        let metadataPtr = avContext.metadata
//
//        var metadata: [String: String] = [:]
//        var tagPtr: UnsafeMutablePointer<AVDictionaryEntry>?
//
//        while let tag = av_dict_get(metadataPtr, "", tagPtr, AV_DICT_IGNORE_SUFFIX) {
//
//            metadata[String(cString: tag.pointee.key)] = String(cString: tag.pointee.value)
//            tagPtr = tag
//        }
//
//        print("\nMetadata for file:\n\(metadata)\n")
//    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString", String.self]!
