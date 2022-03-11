//
//  ColorSchemesManager+Observer.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol ColorSchemeObserver {
    
    func colorChanged(to newColor: PlatformColor)
}

extension ColorSchemesManager {
    
    func startObserving() {
        
        for property in registry.keys {
            beginKVO(forProperty: property)
        }
    }
    
    // TODO: Call this from AppModeManager.dismissMode()
    func stopObserving() {
        
        registry.removeAll()
        kvo.invalidate()
    }
    
    private func beginKVO(forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        kvo.addObserver(forObject: systemColorScheme, keyPath: property) {[weak self] newColor in
            
            guard let observers = self?.registry[property] else {return}
            
            observers.forEach {
                $0.colorChanged(to: newColor)
            }
        }
    }
    
    func registerObserver(_ observer: ColorSchemeObserver, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if registry[property] == nil {
            registry[property] = []
        }
        
        registry[property]!.append(observer)
    }
    
    func registerObservers(_ observers: [ColorSchemeObserver], forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if registry[property] == nil {
            registry[property] = []
        }
        
        registry[property]!.append(contentsOf: observers)
    }
    
    func registerObserver(_ observer: ColorSchemeObserver, forProperties properties: KeyPath<ColorScheme, PlatformColor>...) {
        
        for property in properties {
            
            if registry[property] == nil {
                registry[property] = []
            }
            
            registry[property]!.append(observer)
        }
    }
}
