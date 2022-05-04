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
            
            kvo.addObserver(forObject: systemScheme, keyPath: property) {[weak self] _, newColor in
                
                guard let observers = self?.propertyObservers[property] else {return}
                
                observers.forEach {
                    $0.colorChanged(to: newColor, forProperty: property)
                }
            }
        }
        
        for property in schemeAndPropertyObservers.keys {
            
            kvo.addObserver(forObject: systemScheme, keyPath: property, options: [.new]) {[weak self] _, newColor in
                
                guard let strongSelf = self, !strongSelf.schemeChanged,
                      let observers = strongSelf.schemeAndPropertyObservers[property] else {return}
                
                observers.forEach {
                    $0.colorChanged(to: newColor, forProperty: property)
                }
            }
        }
        
        for observer in schemeObservers {
            observer.colorSchemeChanged()
        }
        
        isObserving = true
    }
    
    // TODO: Call this from AppModeManager.dismissMode()
    func stopObserving() {
        
        propertyObservers.removeAll()
        schemeAndPropertyObservers.removeAll()
        schemeObservers.removeAll()
        
        kvo.invalidate()
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
    }
    
    func registerSchemeObservers(_ observers: [ColorSchemeObserver], forProperties properties: [KeyPath<ColorScheme, PlatformColor>]) {
        
        schemeObservers.append(contentsOf: observers)
        
        for observer in observers {
            
            for property in properties {
                
                if schemeAndPropertyObservers[property] == nil {
                    schemeAndPropertyObservers[property] = []
                }
                
                schemeAndPropertyObservers[property]!.append(observer)
            }
            
            if isObserving {
                observer.colorSchemeChanged()
            }
            
            // TODO: Add to reverse registry
        }
    }
    
    private func doRegisterObservers(_ observers: [PropertyObserver]) {
        
        for (observer, property) in observers {
            
            if propertyObservers[property] == nil {
                propertyObservers[property] = []
            }
            
            propertyObservers[property]!.append(observer)
            
            if let observerObject = observer as? NSObject {
                reverseRegistry[observerObject] = property
            }
            
            if isObserving {
                observer.colorChanged(to: systemColorScheme[keyPath: property], forProperty: property)
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
