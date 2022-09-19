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
        
        print("\nUser Docs Dir: \(userDocumentsDirectory.exists)")
        
//        do {
//            try FileManager.default.copyItem(at: , to: dstURL)
//        } catch {}
        
        for child in userDocumentsDirectory.children ?? [] {
            print("\nChild: \(child.lastPathComponent)")
        }
        
        playQueueDelegate.loadTracks(from: userDocumentsDirectory.children ?? [], autoplay: false)
        
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
