//
//  MappedObjects.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A contract for a generic user-managed object (eg. preset / playlist) that can be mapped to a key.
///
protocol UserManagedObject: MenuItemMappable {
    
    var key: String {get set}
    
    var userDefined: Bool {get}
}

///
/// A utility to perform CRUD operations on an ordered / mapped collection
/// of **UserManagedObject** objects.
///
/// - SeeAlso: `UserManagedObject`
///
class UserManagedObjects<O: UserManagedObject> {
    
    private let userDefinedObjectsMap: UserManagedObjectsMap<O> = UserManagedObjectsMap()
    private let systemDefinedObjectsMap: UserManagedObjectsMap<O> = UserManagedObjectsMap()
    
    var userDefinedObjects: [O] {userDefinedObjectsMap.allObjects}
    var systemDefinedObjects: [O] {systemDefinedObjectsMap.allObjects}
    
    var defaultPreset: O? {nil}
    
    init(systemDefinedObjects: [O], userDefinedObjects: [O]) {
        
        systemDefinedObjects.forEach {
            self.systemDefinedObjectsMap.addObject($0)
        }
        
        userDefinedObjects.forEach {
            self.userDefinedObjectsMap.addObject($0)
        }
    }
    
    func addObject(_ object: O) {
        userDefinedObjectsMap.addObject(object)
    }
    
    func object(named name: String) -> O? {
        systemDefinedObjectsMap[name] ?? userDefinedObjectsMap[name]
    }

    var numberOfUserDefinedObjects: Int {userDefinedObjectsMap.count}
    
    func userDefinedObject(named name: String) -> O? {
        userDefinedObjectsMap[name]
    }
    
    func systemDefinedObject(named name: String) -> O? {
        systemDefinedObjectsMap[name]
    }
    
    @discardableResult func deleteObject(atIndex index: Int) -> O {
        return userDefinedObjectsMap.removeObjectAtIndex(index)
    }
    
    @discardableResult func deleteObjects(atIndices indices: IndexSet) -> [O] {
        
        return indices.sortedDescending().map {
            userDefinedObjectsMap.removeObjectAtIndex($0)
        }
    }
    
    @discardableResult func deleteObject(named name: String) -> O? {
        return userDefinedObjectsMap.removeObject(withKey: name)
    }
    
    @discardableResult func deleteObjects(named objectNames: [String]) -> [O] {
        
        return objectNames.compactMap {
            deleteObject(named: $0)
        }
    }
    
    func renameObject(named oldName: String, to newName: String) {
        userDefinedObjectsMap.reMap(objectWithKey: oldName, toKey: newName)
    }
    
    func objectExists(named name: String) -> Bool {
        userDefinedObjectsMap.objectWithKeyExists(name) || systemDefinedObjectsMap.objectWithKeyExists(name)
    }
    
    func userDefinedObjectExists(named name: String) -> Bool {
        userDefinedObjectsMap.objectWithKeyExists(name)
    }
    
    func sortUserDefinedObjects(by sortFunction: (O, O) -> Bool) {
        userDefinedObjectsMap.sortObjects(by: sortFunction)
    }
}

///
/// A specialized collection that functions as both an array and dictionary for **UserManagedObject** objects
/// so that the objects can be accessed efficiently both by index and key.
///
fileprivate class UserManagedObjectsMap<O: UserManagedObject> {
    
    private var array: [O] = []
    private var map: [String: O] = [:]
    
    subscript(_ index: Int) -> O {
        array[index]
    }
    
    subscript(_ key: String) -> O? {
        map[key]
    }
    
    func addObject(_ object: O) {
        
        array.append(object)
        map[object.key] = object
    }
    
    func removeObject(withKey key: String) -> O? {
        
        guard let index = array.firstIndex(where: {$0.key == key}) else {return nil}
        
        map.removeValue(forKey: key)
        return array.remove(at: index)
    }
    
    func reMap(objectWithKey oldKey: String, toKey newKey: String) {
        
        if var object = map[oldKey] {

            // Modify the key within the object
            object.key = newKey
            
            // Re-map the object to the new key
            map.removeValue(forKey: oldKey)
            map[newKey] = object
        }
    }
    
    func removeObjectAtIndex(_ index: Int) -> O {
        
        let object = array[index]
        map.removeValue(forKey: object.key)
        return array.remove(at: index)
    }
    
    func objectWithKeyExists(_ key: String) -> Bool {
        map[key] != nil
    }
    
    func sortObjects(by sortFunction: (O, O) -> Bool) {
        array.sort(by: sortFunction)
    }
    
    var count: Int {array.count}
    
    var allObjects: [O] {array}
}
