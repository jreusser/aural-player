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
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>)
}

extension ColorSchemesManager {
    
    static let muthu: Int = 5
    
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
        
        kvo.addObserver(forObject: systemColorScheme, keyPath: property) {[weak self] _, newColor in
            
            guard let observers = self?.registry[property] else {return}
            
            observers.forEach {
                $0.colorChanged(to: newColor, forProperty: property)
            }
        }
    }
    
    func registerObserver(_ observer: ColorSchemeObserver, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if registry[property] == nil {
            registry[property] = []
        }
        
        registry[property]!.append(observer)
        
        observer.colorChanged(to: systemColorScheme[keyPath: property], forProperty: property)
        
        if let observerObject = observer as? NSObject {
            reverseRegistry[observerObject] = property
        }
    }
    
    func removeObserver(_ observer: ColorSchemeObserver) {
        
        if let observerObject = observer as? NSObject, let property = reverseRegistry[observerObject] {
            
            // TODO: Observers for a property should be a Set, not an array. Make ColorSchemeObserver extend from Hashable.
            if var observers = registry[property] {
                
                observers.removeAll(where: {($0 as? NSObject) === (observer as? NSObject)})
                registry[property] = observers
            }
            
            reverseRegistry.removeValue(forKey: observerObject)
        }
    }
    
    func registerObservers(_ observers: [ColorSchemeObserver], forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if registry[property] == nil {
            registry[property] = []
        }
        
        registry[property]!.append(contentsOf: observers)
        
        for observer in observers {
            observer.colorChanged(to: systemColorScheme[keyPath: property], forProperty: property)
        }
    }
    
    func registerObserver(_ observer: ColorSchemeObserver, forProperties properties: KeyPath<ColorScheme, PlatformColor>...) {

        for property in properties {

            if registry[property] == nil {
                registry[property] = []
            }

            registry[property]!.append(observer)

            observer.colorChanged(to: systemColorScheme[keyPath: property], forProperty: property)
        }
    }
}
