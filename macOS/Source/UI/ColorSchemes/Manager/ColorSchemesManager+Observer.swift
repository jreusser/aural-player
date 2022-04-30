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

protocol ColorSchemePropertyObserver {
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>)
}

protocol ColorSchemeObserver: ColorSchemePropertyObserver {
    
    func colorSchemeChanged()
}

typealias ColorSchemePropertyObserverFunction = (PlatformColor) -> Void

extension ColorSchemesManager {
    
    func startObserving() {
        
        for property in propertyObservers.keys {
            beginKVO(forProperty: property)
        }
        
        for property in schemeAndPropertyObservers.keys {
            beginKVO(forProperty: property, options: [.new], isSchemeObserver: true)
        }
    }
    
    // TODO: Call this from AppModeManager.dismissMode()
    func stopObserving() {
        
        propertyObservers.removeAll()
        schemeAndPropertyObservers.removeAll()
        schemeObservers.removeAll()
        
        kvo.invalidate()
    }
    
    private func beginKVO(forProperty property: KeyPath<ColorScheme, PlatformColor>, options: NSKeyValueObservingOptions = [.initial, .new], isSchemeObserver: Bool = false) {
        
        kvo.addObserver(forObject: systemScheme, keyPath: property) {[weak self] _, newColor in
            
            guard let strongSelf = self,
                    !(isSchemeObserver && strongSelf.schemeChanged),
                    let observers = strongSelf.propertyObservers[property] else {return}
            
            observers.forEach {
                $0.colorChanged(to: newColor, forProperty: property)
            }
        }
    }
    
    private typealias PropertyObserver = (observer: ColorSchemePropertyObserver, property: KeyPath<ColorScheme, PlatformColor>)
    
    func registerObserver(_ observer: ColorSchemePropertyObserver, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        doRegisterObservers([(observer, property)])
    }
    
    func registerObserver(_ observer: ColorSchemePropertyObserver, forProperties properties: [KeyPath<ColorScheme, PlatformColor>]) {
        doRegisterObservers(properties.map {(observer, $0)})
    }
    
    func registerObservers(_ observers: [ColorSchemePropertyObserver], forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        doRegisterObservers(observers.map {($0, property)})
    }
    
    func registerSchemeObserver(_ observer: ColorSchemeObserver, forProperties properties: [KeyPath<ColorScheme, PlatformColor>]) {
        
        schemeObservers.append(observer)
        
        for property in properties {
            
            if schemeAndPropertyObservers[property] == nil {
                schemeAndPropertyObservers[property] = []
            }
            
            schemeAndPropertyObservers[property]!.append(observer)
            
            // TODO: Add to reverse registry
        }
        
        observer.colorSchemeChanged()
    }
    
    private func doRegisterObservers(_ observers: [PropertyObserver], initialize: Bool = true) {
        
        for (observer, property) in observers {
            
            if propertyObservers[property] == nil {
                propertyObservers[property] = []
            }
            
            propertyObservers[property]!.append(observer)
            
            if initialize {
                observer.colorChanged(to: systemScheme[keyPath: property], forProperty: property)
            }
            
            if let observerObject = observer as? NSObject {
                reverseRegistry[observerObject] = property
            }
        }
    }
    
    func removeObserver(_ observer: ColorSchemePropertyObserver) {
        
        guard let observerObject = observer as? NSObject, let property = reverseRegistry[observerObject] else {return}
        
        // TODO: Observers for a property should be a Set, not an array. Make ColorSchemePropertyObserver extend from Hashable.
        if var observers = propertyObservers[property] {
            
            observers.removeAll(where: {($0 as? NSObject) === (observer as? NSObject)})
            propertyObservers[property] = observers
        }
        
        reverseRegistry.removeValue(forKey: observerObject)
    }
}
