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
        
        let audioGraph = objectGraph.audioGraphDelegate
        
        // TODO: Handle adding / removing of AUs.
        
        for unit in audioGraph.allUnits {
            
            unit.observeState {[weak self] newState in
                
                for observer in self?.registry[unit.unitType] ?? [] {
                    observer.unitStateChanged(to: newState)
                }
            }
        }
        
        kvoTokens.append(systemColorScheme.observe(\.activeControlColor, options: [.initial, .new]) {[weak self] _,_ in
            
            // Redraw all observers of active units.
            
            for unit in audioGraph.allUnits.filter({$0.isActive}) {
                
                for observer in self?.registry[unit.unitType] ?? [] {
                    
                    if let tintableObserver = observer as? TintableFXUnitStateObserver {
                        tintableObserver.contentTintColor = systemColorScheme.activeControlColor
                        
                    } else if let textualObserver = observer as? TextualFXUnitStateObserver {
                        textualObserver.textColor = systemColorScheme.activeControlColor
                        
                    } else {
                        observer.redraw()
                    }
                }
            }
        })
        
        kvoTokens.append(systemColorScheme.observe(\.bypassedControlColor, options: [.initial, .new]) {[weak self] _,_ in
            
            // Redraw all observers of bypassed units.
            
            for unit in audioGraph.allUnits.filter({$0.state == .bypassed}) {
                
                for observer in self?.registry[unit.unitType] ?? [] {
                    
                    if let tintableObserver = observer as? TintableFXUnitStateObserver {
                        tintableObserver.contentTintColor = systemColorScheme.bypassedControlColor
                        
                    } else if let textualObserver = observer as? TextualFXUnitStateObserver {
                        textualObserver.textColor = systemColorScheme.bypassedControlColor
                        
                    } else {
                        observer.redraw()
                    }
                }
            }
        })
        
        kvoTokens.append(systemColorScheme.observe(\.suppressedControlColor, options: [.initial, .new]) {[weak self] _,_ in
            
            // Redraw all observers of suppressed units.
            
            for unit in audioGraph.allUnits.filter({$0.state == .suppressed}) {
                
                for observer in self?.registry[unit.unitType] ?? [] {
                    
                    if let tintableObserver = observer as? TintableFXUnitStateObserver {
                        tintableObserver.contentTintColor = systemColorScheme.suppressedControlColor
                        
                    } else if let textualObserver = observer as? TextualFXUnitStateObserver {
                        textualObserver.textColor = systemColorScheme.suppressedControlColor
                        
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
        
        let object = observer as! NSObject
        return reverseRegistry[object]!.state
    }
}

let fxUnitStateObserverRegistry: EffectsUnitStateObserverRegistry = .shared
