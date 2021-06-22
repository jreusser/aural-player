import Foundation
import AVFoundation

/*
    Enumeration of all possible reverb effect presets
 */
enum ReverbSpaces: String {
    
    case smallRoom
    
    case mediumRoom
    
    case largeRoom
    
    case mediumHall
    
    case largeHall
    
    case mediumChamber
    
    case largeChamber
    
    case cathedral
    
    case plate
    
    // Maps a ReverbSpaces to a AVAudioUnitReverbPreset
    var avPreset: AVAudioUnitReverbPreset {
        
        switch self {
            
        case .smallRoom: return .smallRoom
        case .mediumRoom: return .mediumRoom
        case .largeRoom: return .largeRoom
            
        case .mediumHall: return .mediumHall
        case .largeHall: return .largeHall
            
        case .mediumChamber: return .mediumChamber
        case .largeChamber: return .largeChamber
            
        case .cathedral: return .cathedral
        case .plate: return .plate
            
        }
    }
    
    // Maps a AVAudioUnitReverbPreset to a ReverbPresets
    static func mapFromAVPreset(_ preset: AVAudioUnitReverbPreset) -> ReverbSpaces {
        
        switch preset {
            
        case .smallRoom: return .smallRoom
        case .mediumRoom: return .mediumRoom
        case .largeRoom: return .largeRoom
            
        case .mediumHall: return .mediumHall
        case .largeHall: return .largeHall
            
        case .mediumChamber: return .mediumChamber
        case .largeChamber: return .largeChamber
            
        case .cathedral: return .cathedral
        case .plate: return .plate
            
        // This should never happen
        default: return ReverbSpaces.smallRoom
            
        }
    }
    
    // User-friendly, UI-friendly description string
    var description: String {
        rawValue.splitAsCamelCaseWord(capitalizeEachWord: false)
    }
 
    // Constructs a ReverPresets object from a description string
    static func fromDescription(_ description: String) -> ReverbSpaces {
        return ReverbSpaces(rawValue: description.camelCased()) ?? AppDefaults.reverbSpace
    }
}
