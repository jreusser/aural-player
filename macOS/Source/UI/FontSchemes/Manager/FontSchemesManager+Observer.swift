//
//  FontSchemesManager+Observer.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol FontSchemeObserver {
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>)
}

extension FontSchemesManager {
    
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
    
    private func beginKVO(forProperty property: KeyPath<FontScheme, PlatformFont>) {
        
        kvo.addObserver(forObject: systemScheme, keyPath: property) {[weak self] _, newFont in
            
            guard let observers = self?.registry[property] else {return}
            
            observers.forEach {
                $0.fontChanged(to: newFont, forProperty: property)
            }
        }
    }
    
    func registerObserver(_ observer: FontSchemeObserver, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        
        if registry[property] == nil {
            registry[property] = []
        }
        
        registry[property]!.append(observer)
        
        observer.fontChanged(to: systemScheme[keyPath: property], forProperty: property)
        
        if let observerObject = observer as? NSObject {
            reverseRegistry[observerObject] = property
        }
    }
    
    func removeObserver(_ observer: FontSchemeObserver) {
        
        if let observerObject = observer as? NSObject, let property = reverseRegistry[observerObject] {
            
            // TODO: Observers for a property should be a Set, not an array. Make FontSchemeObserver extend from Hashable.
            if var observers = registry[property] {
                
                observers.removeAll(where: {($0 as? NSObject) === (observer as? NSObject)})
                registry[property] = observers
            }
            
            reverseRegistry.removeValue(forKey: observerObject)
        }
    }
    
    func registerObservers(_ observers: [FontSchemeObserver], forProperty property: KeyPath<FontScheme, PlatformFont>) {
        
        if registry[property] == nil {
            registry[property] = []
        }
        
        registry[property]!.append(contentsOf: observers)
        
        for observer in observers {
            observer.fontChanged(to: systemScheme[keyPath: property], forProperty: property)
        }
    }
    
    func registerObserver(_ observer: FontSchemeObserver, forProperties properties: KeyPath<FontScheme, PlatformFont>...) {

        for property in properties {

            if registry[property] == nil {
                registry[property] = []
            }

            registry[property]!.append(observer)

            observer.fontChanged(to: systemScheme[keyPath: property], forProperty: property)
        }
    }
}
