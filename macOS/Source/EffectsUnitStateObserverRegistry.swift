//
//  EffectsUnitStateObserverRegistry.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class EffectsUnitStateObserverRegistry {
    
    static let shared: EffectsUnitStateObserverRegistry = .init()
    
    private var kvoTokens: [NSKeyValueObservation] = []
    
    private init() {
        
        // TODO: Handle adding / removing of AUs.
        
        for unit in audioGraphDelegate.allUnits {
            
            unit.observeState {[weak self] newState in
                
                for observer in self?.registry[unit.unitType] ?? [] {
                    observer.unitStateChanged(to: newState)
                }
            }
        }
        
        observeColor(property: \.activeControlColor, forUnitState: .active)
        observeColor(property: \.inactiveControlColor, forUnitState: .bypassed)
        observeColor(property: \.suppressedControlColor, forUnitState: .suppressed)
    }
    
    private func observeColor(property: KeyPath<ColorScheme, PlatformColor>, forUnitState state: EffectsUnitState) {
        
        kvoTokens.append(systemColorScheme.observe(property, options: [.initial, .new]) {[weak self] _,_ in
            
            // Redraw all observers of active units.
            
            let newColor: PlatformColor = systemColorScheme[keyPath: property]
            
            for unit in audioGraphDelegate.allUnits.filter({$0.state == state}) {
                
                guard let observers = self?.registry[unit.unitType] else {continue}
                
                for observer in observers {
                    
                    if let tintableObserver = observer as? TintableFXUnitStateObserver {
                        tintableObserver.contentTintColor = newColor
                        
                    } else if let textualObserver = observer as? TextualFXUnitStateObserver {
                        textualObserver.textColor = newColor
                        
                    } else {
                        observer.redraw()
                    }
                }
            }
        })
    }
    
    private var registry: [EffectsUnitType: [FXUnitStateObserver]] = [:]
    
    private var reverseRegistry: [NSObject: EffectsUnitDelegateProtocol] = [:]
    
    func registerObserver(_ observer: FXUnitStateObserver, forFXUnit fxUnit: EffectsUnitDelegateProtocol) {
        
        if registry[fxUnit.unitType] == nil {
            registry[fxUnit.unitType] = []
        }
        
        registry[fxUnit.unitType]!.append(observer)
        
        if let object = observer as? NSObject {
            reverseRegistry[object] = fxUnit
        }
        
        // Set initial value.
        observer.unitStateChanged(to: fxUnit.state)
    }
    
    func currentState(forObserver observer: FXUnitStateObserver) -> EffectsUnitState {
        
        guard let object = observer as? NSObject else {return .bypassed}
        return reverseRegistry[object]?.state ?? .bypassed
    }
}

let fxUnitStateObserverRegistry: EffectsUnitStateObserverRegistry = .shared
