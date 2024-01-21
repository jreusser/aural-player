//
//  ColorSchemesManager+Observer.swift
//  Aural-macOS
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import AppKit

protocol ColorSchemePropertyObserver {
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>)
}

protocol ColorSchemeObserver: ColorSchemePropertyObserver {
    
    func colorSchemeChanged()
}

typealias ColorSchemePropertyObserverFunction = (PlatformColor) -> Void

extension ColorSchemesManager {
    
    // TODO: Call this from AppModeManager.dismissMode()
    func stopObserving() {
        
        propertyObservers.removeAll()
        schemeAndPropertyObservers.removeAll()
        schemeObservers.removeAll()
        
        propertyKVO.invalidate()
        schemeKVO.invalidate()
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
    
    func registerObservers(_ observers: [ColorSchemePropertyObserver], forProperties properties: [KeyPath<ColorScheme, PlatformColor>]) {
        
        var tuples: [PropertyObserver] = []
        
        for observer in observers {
            
            for property in properties {
                tuples.append((observer, property))
            }
        }
        
        doRegisterObservers(tuples)
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
            observer.colorChanged(to: systemScheme[keyPath: property], forProperty: property)
        }
    }
    
    private func observeProperty(_ property: KeyPath<ColorScheme, PlatformColor>) {
        
        propertyKVO.addObserver(forObject: systemScheme, keyPath: property, options: [.new]) {[weak self] _, newColor in
            
            guard let observers = self?.propertyObservers[property] else {return}
            
            observers.forEach {
                $0.colorChanged(to: newColor, forProperty: property)
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
    
    // ----------------------------------------------------------------------------------------------------
    
    // MARK: Scheme observing
    
    func registerSchemeObserver(_ observer: ColorSchemeObserver, forProperties properties: [KeyPath<ColorScheme, PlatformColor>]) {
        registerSchemeObservers([observer], forProperties: properties)
    }
    
    func registerSchemeObservers(_ observers: [ColorSchemeObserver], forProperties properties: [KeyPath<ColorScheme, PlatformColor>]) {
        
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
            observer.colorSchemeChanged()
        }
    }
    
    private func observePropertyForSchemeObserver(_ property: KeyPath<ColorScheme, PlatformColor>) {
        
        schemeKVO.addObserver(forObject: systemScheme, keyPath: property, options: [.new]) {[weak self] _, newColor in
            
            guard let strongSelf = self else {return}
                    
            if strongSelf.schemeChanged {return}
            
            if let observers = strongSelf.schemeAndPropertyObservers[property] {
            
                observers.forEach {
                    $0.colorChanged(to: newColor, forProperty: property)
                }
            }
        }
    }
}
