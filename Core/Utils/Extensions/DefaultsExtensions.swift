//
//  UserDefaultsExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension UserDefaults {

    subscript<T: Any>(_ key: String, type: T.Type) -> T? {

        get {
            object(forKey: key) as? T
            
            let isEnum: Bool = T.Type is RawRepresentable
        }
        
        set {
            setValue(newValue, forKey: key)
        }
    }

//    func enumValue<T: RawRepresentable>(forKey key: String, ofType: T.Type) -> T? where T.RawValue == String {
//
//        if let string = self.string(forKey: key) {
//            return T(rawValue: string)
//        }
//
//        return nil
//    }
    
    subscript<T: RawRepresentable>(_ key: String, enumType: T.Type) -> T? where T.RawValue == String {

        get {
            
            if let strValue = string(forKey: key) {
                return T.init(rawValue: strValue)
            }
            
            return nil
        }
        
        set {
            setValue(newValue?.rawValue, forKey: key)
        }
    }

    func urlValue(forKey key: String) -> URL? {

        if let string = self.string(forKey: key) {
            return URL(fileURLWithPath: string)
        }

        return nil
    }
}
