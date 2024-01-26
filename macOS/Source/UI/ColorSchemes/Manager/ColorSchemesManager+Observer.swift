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

protocol ColorSchemeObserver {
    
    func colorSchemeChanged()
    
    var hashValue: Int {get}
}

protocol ColorSchemePropertyObserver {
    
    var hashValue: Int {get}
}

typealias ColorSchemePropertyChangeHandler = (PlatformColor) -> Void
typealias ColorSchemeProperty = KeyPath<ColorScheme, PlatformColor>

extension ColorSchemesManager {
    
    func stopObserving() {
        
        for (prop, var map) in propertyObservers {
            map.removeAll()
        }
        propertyObservers.removeAll()
        schemeObservers.removeAll()
    }
    
    func registerSchemeObserver(_ observer: ColorSchemeObserver) {
        
        schemeObservers[observer.hashValue] = observer
        observer.colorSchemeChanged()
    }
    
    func registerPropertyObserver(_ observer: ColorSchemePropertyObserver, forProperty property: ColorSchemeProperty, 
                                  handler: @escaping ColorSchemePropertyChangeHandler) {
        
        if propertyObservers[property] == nil {
            propertyObservers[property] = [:]
        }
        
        propertyObservers[property]![observer.hashValue] = handler
        
        // Set initial value.
        handler(systemScheme[keyPath: property])
    }
    
    func removePropertyObserver(_ observer: ColorSchemePropertyObserver, forProperty property: ColorSchemeProperty) {
        propertyObservers[property]?.removeValue(forKey: observer.hashValue)
    }
    
    func removeSchemeObserver(_ observer: ColorSchemeObserver) {
        schemeObservers.removeValue(forKey: observer.hashValue)
    }
    
//    func registerObserver(_ observer: ColorSchemeObserver, forProperties properties: [ColorSchemeProperty]) {
//        doRegisterObservers(properties.map {(observer, $0)})
//    }
//    
//    func registerObservers(_ observers: [ColorSchemeObserver], forProperty property: ColorSchemeProperty) {
//        doRegisterObservers(observers.map {($0, property)})
//    }
    
//    func registerObservers(_ observers: [ColorSchemeObserver], forProperties properties: [ColorSchemeProperty]) {
//        
//        var tuples: [SchemePropertyObserver] = []
//        
//        for observer in observers {
//            
//            for property in properties {
//                tuples.append((observer, property))
//            }
//        }
//        
//        doRegisterObservers(tuples)
//    }
    
//    private func doRegisterObservers(_ observers: [SchemePropertyObserver]) {
//        
//        for (observer, property) in observers {
//            
//            if propertyObservers[property] == nil {
//                propertyObservers[property] = []
//            }
//            
//            propertyObservers[property]!.append(observer)
//            
//            if let observerObject = observer as? NSObject {
//                reverseRegistry[observerObject] = property
//            }
//            
//            // Set initial value.
//            observer.colorChanged(to: systemScheme[keyPath: property], forProperty: property)
//        }
//    }
}
