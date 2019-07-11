//
//  UserDefaultsCache.swift
//  FileCache
//
//  Created by Brandon Bro on 7/9/19.
//  Copyright © 2019 Brandon Bro. All rights reserved.
//

import Foundation

/// Object for managing User Defaults Objects in Non Volatile memory. Allows for caching / saving of objects that conform to Codable protocol.
public class UserDefaultsCache: Cacheable {
    
    private let defaults: UserDefaults
    
    /// Creates an instance with a UserDefaults domain / suite.
    ///
    /// - Parameter the namespace used for the suit name, defaults to standard.
    public init(namespace: Namespace) {

        self.defaults = UserDefaults(suiteName: namespace.name) ?? UserDefaults.standard
    }
    
    /// Saves an object that conforms to Codable protocol for a given key.
    ///
    /// - Parameters:
    ///   - item: Object conforming to Codable.
    ///   - key: The key used to save the object.
    public func save<T: Codable>(_ item: T, key: CacheKey) {
        
        guard let encoded = encode(item) else {
            return
        }
        
        defaults.setValue(encoded, forKeyPath: key)
        print("UserDefaultsCache: Successfully saved item: \(item) for key: \(key) in \(defaults)")
    }
    
    /// Loads a Codable object from the cache.
    ///
    /// - Parameters:
    ///   - _: The Codable Object type. ex: CustomObject.Type
    ///   - key: The identidier to associate the object being stored with.
    /// - Returns: The object type decoded.
    public func load<T: Codable>(_:T.Type, key: CacheKey) -> T? {
        
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        
        print("UserDefaultsCache: Successfully loaded item: \(T.self) for key: \(key)")
        return decode(T.self, for: data)
        
    }
    
    /// Removes a single object assoicated with a key,
    ///
    /// - Parameter key: The lookup key assoicated with the object stored.
    public func clear(_ key: CacheKey) {
        
        guard isKeyPresent(key: key) else {
            return
        }
        
        defaults.removeObject(forKey: key)
        print("UserDefaultsCache: Successfully removed item for key: \(key)")
    }
    
    /// Removes all keys and values from the suite or domain.
    ///
    /// - Parameter namespace: the name of the domain or suite to remove the key / values from.
    public func clearAll(_ namespace: Namespace) {
        defaults.removePersistentDomain(forName: namespace.name)
    }
    
    public func allValues() -> [String:Any] {
        return defaults.dictionaryRepresentation()
    }
    
}

extension UserDefaultsCache {

    private func encode<T: Codable>(_ item: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(item.self)
            return encoded
        }
        catch(let error) {
            print("UserDefaultsCache: Failed attempting to encode: \(item), reason: \(error)")
            return nil
        }
    }
    
    private func decode<T: Codable>(_:T.Type, for data: Data) -> T? {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        }
        catch(let error) {
            print("UserDefaultsCache: Failed to decode the object for type: \(T.self), reason: \(error)")
            return nil
        }
    }
    
    private func isKeyPresent(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
}
