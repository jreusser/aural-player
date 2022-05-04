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

protocol FontSchemePropertyObserver {
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>)
}

protocol FontSchemeObserver: FontSchemePropertyObserver {
    
    func fontSchemeChanged()
}

extension FontSchemesManager {
    
    func startObserving() {
        
        for property in propertyObservers.keys {
            
            kvo.addObserver(forObject: systemScheme, keyPath: property) {[weak self] _, newFont in
                
                guard let observers = self?.propertyObservers[property] else {return}
                
                observers.forEach {
                    $0.fontChanged(to: newFont, forProperty: property)
                }
            }
        }
        
        for property in schemeAndPropertyObservers.keys {
            
            kvo.addObserver(forObject: systemScheme, keyPath: property, options: [.new]) {[weak self] _, newFont in
                
                guard let strongSelf = self, !strongSelf.schemeChanged,
                      let observers = strongSelf.schemeAndPropertyObservers[property] else {return}
                
                observers.forEach {
                    $0.fontChanged(to: newFont, forProperty: property)
                }
            }
        }
        
        for observer in schemeObservers {
            observer.fontSchemeChanged()
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
    
    private typealias PropertyObserver = (observer: FontSchemePropertyObserver, property: KeyPath<FontScheme, PlatformFont>)
    
    func registerObserver(_ observer: FontSchemePropertyObserver, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        doRegisterObservers([(observer, property)])
    }
    
    func registerObserver(_ observer: FontSchemePropertyObserver, forProperties properties: [KeyPath<FontScheme, PlatformFont>]) {
        doRegisterObservers(properties.map {(observer, $0)})
    }
    
    func registerObservers(_ observers: [FontSchemePropertyObserver], forProperty property: KeyPath<FontScheme, PlatformFont>) {
        doRegisterObservers(observers.map {($0, property)})
    }
    
    func registerSchemeObserver(_ observer: FontSchemeObserver, forProperties properties: [KeyPath<FontScheme, PlatformFont>]) {
        
        schemeObservers.append(observer)
        
        for property in properties {
            
            if schemeAndPropertyObservers[property] == nil {
                schemeAndPropertyObservers[property] = []
            }
            
            schemeAndPropertyObservers[property]!.append(observer)
            
            // TODO: Add to reverse registry
            
            if isObserving {
                observer.fontSchemeChanged()
            }
        }
    }
    
    func registerSchemeObservers(_ observers: [FontSchemeObserver], forProperties properties: [KeyPath<FontScheme, PlatformFont>]) {
        
        schemeObservers.append(contentsOf: observers)
        
        for observer in observers {
            
            for property in properties {
                
                if schemeAndPropertyObservers[property] == nil {
                    schemeAndPropertyObservers[property] = []
                }
                
                schemeAndPropertyObservers[property]!.append(observer)
            }
            
            // TODO: Add to reverse registry
            
            if isObserving {
                observer.fontSchemeChanged()
            }
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
                observer.fontChanged(to: systemFontScheme[keyPath: property], forProperty: property)
            }
        }
    }
    
    func removeObserver(_ observer: FontSchemePropertyObserver) {
        
        guard let observerObject = observer as? NSObject, let property = reverseRegistry[observerObject] else {return}
        
        // TODO: Observers for a property should be a Set, not an array. Make FontSchemePropertyObserver extend from Hashable.
        if var observers = propertyObservers[property] {
            
            observers.removeAll(where: {($0 as? NSObject) === (observer as? NSObject)})
            propertyObservers[property] = observers
        }
        
        reverseRegistry.removeValue(forKey: observerObject)
    }
}
