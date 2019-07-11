//
//  VolatileCache.swift
//  FileCache
//
//  Created by Brandon Bro on 7/9/19.
//  Copyright © 2019 Brandon Bro. All rights reserved.
//

import Foundation

/// In memory volatile (non persisting) caching structure. Note we must provide a concerete imp. which uses NSCache since we can not simply extend NSCache since it can not support generics, or encoable / decodable protocols. Additionally we can not exetend a dictionary to impliment AppCache in this case since Dictionarys are structs and have mutating members.
/// Note:: NSCache is thread safe.

public struct VolatileCache<T: Codable> {
    
    private var cache: NSCache = NSCache<AnyObject, AnyObject>()
    
    private var decoder: JSONDecoder = JSONDecoder()
    private var encoder: JSONEncoder = JSONEncoder()
    
    /// Initalizer
    public init() {}
    
    /// Loads an item from the internal cache in memory.
    ///
    /// - Parameters:
    ///   - _: The item type to be returned.
    ///   - key: The lookup key to locate the item to be returned by.
    /// - Returns: An object conforming to Codable protocol if found or nil if not.
    public func load(key: CacheKey) -> T? {
        
        guard let data = cache.object(forKey: key as AnyObject) as? Data else {
            return nil
        }
        
        return decode(T.self, for: data)
    }
    
    /// Saves an item into cache, note this is volatile ex: simillar to in memory dictionary.
    ///
    /// - Parameters:
    ///   - item: The item conforming to protocol to be saved.
    ///   - key: The identifiying key to locate the item by.
    public func save<T: Codable>(_ item: T, key: CacheKey) {
        
        guard let encoded = encode(item.self) else {
            return
        }
        
        cache.setObject(encoded as AnyObject, forKey: key as AnyObject)
    }
    
    
    /// Removes a given item at the
    ///
    /// - Parameter key: The identifier to find the item to remove.
    public func removeObjectForKey(key: CacheKey) {
        self.cache.removeObject(forKey: key as AnyObject)
    }
    
    /// Removes all items from internal cache structure.
    public func removeAllObjects() {
        self.cache.removeAllObjects()
    }
    
}

extension VolatileCache {
    
    /// Provides a subscript for the interbal cache structure.
    ///
    /// - Parameter key: The key to cache the item with.
    public subscript(key: String) -> T? {
        get {
            return load(key: key)
        }
        set(item) {
            save(item, key: key)
        }
    }
    
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
}
