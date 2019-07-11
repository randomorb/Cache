//
//  AppCache.swift
//  FileCache
//
//  Created by Brandon Bro on 7/9/19.
//  Copyright © 2019 Brandon Bro. All rights reserved.
//

import Foundation

/// Identifier for the object being saved.
public typealias CacheKey = String

/// Interface for any cache on the system, living in volatile or non-volatile memory.
public protocol Cacheable {
    
    /// Returns an object for an identifier if the object is found.
    ///
    /// - Parameters:
    ///   - _: The object type returned.
    ///   - key: The identifier to lookup the object by.
    /// - Returns: Am object of the type that conforms to Codable protocol.
    func load<T: Codable>(_: T.Type, key: CacheKey) -> T?
    
    /// Saves an item into memory
    ///
    /// - Parameters:
    ///   - item: The type being save. ex: Double.Type
    ///   - key: The identifier used to associate the item being saved with.
    func save<T: Codable>(_ item: T, key: CacheKey)
    
    /// Removes a single object from memory.
    ///
    /// - Parameter key: The identifier key used to lookup the object being remvoed.
    func clear(_ key: CacheKey)
    
    /// Removes all objects from a given store in memory.
    ///
    /// - Parameter namespace: The global namespace for the items saved.
    func clearAll(_ namespace: Namespace)
    
}

extension Cacheable {
    
    /// Encodes an object that conforms to Codable protocol.
    ///
    /// - Parameter item: The item wishing to be encoded.
    /// - Returns: Data if the encoding process for the object succeeds.
    public func encode<T: Codable>(_ item: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(item.self)
            return encoded
        }
        catch(let error) {
            print("Failed attempting to encode: \(item), reason: \(error)")
            return nil
        }
    }
    
    /// Decodes an object that conforms to Codable protocol.
    ///
    /// - Parameters:
    ///   - _: The type of the object being decoded.
    ///   - data: The data used to decode from.
    /// - Returns: An optional type of object if the decoding process is successful.
    public func decode<T: Codable>(_:T.Type, for data: Data) -> T? {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        }
        catch(let error) {
            print("Failed to decode the object for type: \(T.self), reason: \(error)")
            return nil
        }
    }
    
}
