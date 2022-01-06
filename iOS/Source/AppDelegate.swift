//
//  AppDelegate.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 06/01/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let engine = AudioEngine()
    lazy var audioGraph = AudioGraph(audioEngine: engine, audioUnitsManager: AudioUnitsManager(), persistentState: nil)
    lazy var scheduler = AVFScheduler(audioGraph.playerNode)
    lazy var player = Player(graph: audioGraph, avfScheduler: scheduler, ffmpegScheduler: scheduler)
    
    let fileReader: FileReader = FileReader()
    
    let userDocumentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    lazy var file = userDocumentsDirectory.appendingPathComponent("Here.mp3")
    lazy var track = Track(file, fileMetadata: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        print("\nUser Docs Dir: \(userDocumentsDirectory)")
        track.playbackContext = try! fileReader.getPlaybackMetadata(for: track.file)
        track.duration = track.playbackContext!.duration
        
        print("\nTrackDuration is: \(track.duration)")
        
        player.play(track, 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("\nSeekPos = \(self.player.seekPosition), Volume: \(self.audioGraph.volume), Muted: \(self.audioGraph.muted)\n")
        }
        
        return true
    }

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
