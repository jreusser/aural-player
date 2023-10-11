//
//  FontSchemesManager+Observer.swift
//  Aural-macOS
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
        
//        for property in propertyObservers.keys {
//            observeProperty(property)
//        }
//
//        for property in schemeAndPropertyObservers.keys {
//            observePropertyForSchemeObserver(property)
//        }
//
//        for observer in schemeObservers {
//            observer.fontSchemeChanged()
//        }
//
//        isObserving = true
    }
    
    // TODO: Call this from AppModeManager.dismissMode()
    func stopObserving() {
        
        propertyObservers.removeAll()
        schemeAndPropertyObservers.removeAll()
        schemeObservers.removeAll()
        
        propertyKVO.invalidate()
        schemeKVO.invalidate()
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
    
    private func doRegisterObservers(_ observers: [PropertyObserver]) {
        
        for (observer, property) in observers {
            
            if propertyObservers[property] == nil {
                propertyObservers[property] = []
            }
            
            propertyObservers[property]!.append(observer)
            
            if let observerObject = observer as? NSObject {
                reverseRegistry[observerObject] = property
            }
            
            if !propertyKVO.isPropertyObserved(property) {
                observeProperty(property)
            }
            
            // Set initial value.
            observer.fontChanged(to: systemScheme[keyPath: property], forProperty: property)
        }
    }
    
    private func observeProperty(_ property: KeyPath<FontScheme, PlatformFont>) {
        
        propertyKVO.addObserver(forObject: systemScheme, keyPath: property, options: [.new]) {[weak self] _, newFont in
            
            guard let observers = self?.propertyObservers[property] else {return}
            
//            if property == \.effectsSecondaryFont {
//                print("\nI have \(observers.count) observers for eff sec.")
//            }
            
            observers.forEach {
                $0.fontChanged(to: newFont, forProperty: property)
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
    
    // ----------------------------------------------------------------------------------------------------
    
    // MARK: Scheme observing
    
    func registerSchemeObserver(_ observer: FontSchemeObserver, forProperties properties: [KeyPath<FontScheme, PlatformFont>]) {
        
        schemeObservers.append(observer)
        
        for property in properties {
            
            if schemeAndPropertyObservers[property] == nil {
                schemeAndPropertyObservers[property] = []
            }
            
            schemeAndPropertyObservers[property]!.append(observer)
            
            // TODO: Add to reverse registry
            
            if !schemeKVO.isPropertyObserved(property) {
                observePropertyForSchemeObserver(property)
            }
            
            observer.fontSchemeChanged()
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
                
                if !schemeKVO.isPropertyObserved(property) {
                    observePropertyForSchemeObserver(property)
                }
            }
            
            // TODO: Add to reverse registry
            
            observer.fontSchemeChanged()
        }
    }
    
    private func observePropertyForSchemeObserver(_ property: KeyPath<FontScheme, PlatformFont>) {
        
        schemeKVO.addObserver(forObject: systemScheme, keyPath: property, options: [.new]) {[weak self] _, newFont in
            
            guard let strongSelf = self else {return}
                    
            guard !strongSelf.schemeChanged else {

                strongSelf.schemeObservers.forEach {
                    $0.fontSchemeChanged()
                }
                
                return
            }
            
            if let observers = strongSelf.schemeAndPropertyObservers[property] {
            
                observers.forEach {
                    $0.fontChanged(to: newFont, forProperty: property)
                }
            }
        }
    }
}
