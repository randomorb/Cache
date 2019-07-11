//
//  FileCache.swift
//  FileCache
//
//  Created by Brandon Bro on 7/9/19.
//  Copyright © 2019 Brandon Bro. All rights reserved.
//

import Foundation

/// Object used for saving non-voltiale objects on disk. Objects intending to be saved must conform to Codeable Protocol.
public class FileCache: Cacheable {
    
    private let fileManager: FileManager = FileManager.default
    
    private let namespace: Namespace
    
    private var namespaceDirectory: URL {
        return makePath(.cachesDirectory, namespace.name)
    }
    
    /// Creates an instance for caching with a given namespace.
    ///
    /// - Parameter namespace: the name of the space reserved for the cache.
    public init(namespace: Namespace) {
        
        self.namespace = namespace
        
        if !directoryExists(for: namespace) {
            self.createDirectiory(for: namespace)
        }
    }
    
    /// Loads a file for a given key from the namespaced cache.
    ///
    /// - Parameters:
    ///   - _: Decodable type returned once read from the file system.
    ///   - key: The name of the file.
    /// - Returns: Decodable type.
    public func load<T: Codable>(_: T.Type, key: CacheKey) -> T? {
        
        let url = namespaceDirectory.appendingPathComponent(key, isDirectory: false)
        
        guard let data = fileManager.contents(atPath: url.path) else {
            return nil
        }
        
        return decode(T.self, for: data)
        
    }
    
    /// Saves the object to disk.
    ///
    /// - Parameters:
    ///   - item: The object to be saved.
    ///   - key: The name to name of the file for the object on disk.
    public func save<T: Codable>(_ item: T, key: CacheKey) {
        
        let url = namespaceDirectory.appendingPathComponent(key, isDirectory: false)
        
        let data = encode(item)
    
        fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
        
    }
    
    /// Clears a given file on disk for a given file name.
    ///
    /// - Parameter key: The name of the file to be cleared.
    public func clear(_ key: CacheKey) {
        
        guard fileExists(for: key) else {
            return
        }
    
        let url = namespaceDirectory.appendingPathComponent(key, isDirectory: false)
        
        do {
            try fileManager.removeItem(at: url)
        }
        catch(let error) {
            print("FileCache: Unable to remove file: \(key) at path: \(url), reason: \(error)")
        }
        
    }
    
    /// Clears the namespace on disk and all files in the namespace.
    ///
    /// - Parameter namespace: the name of the directory to be deleted.
    public func clearAll(_ namespace: Namespace) {
        guard directoryExists(for: namespace) else {
            print("FileCache: Attempting to remove all cache for namespace: \(namespace), but unable to locate the namespace.")
            return
        }
        do {
            try fileManager.removeItem(atPath: namespaceDirectory.path)
        }
        catch(let error) {
            print("FileCache: Unable to remove files at: \(namespaceDirectory), reason: \(error)")
        }
    }
    
}

extension FileCache {
    
    private func makePath(_ searchPath: FileManager.SearchPathDirectory, _ folder: String) -> URL {
        
        guard let searchDirectory = fileManager.urls(for: searchPath, in: .userDomainMask).first else {
            preconditionFailure("FileCache: Unable to create path: \(searchPath), with folder: \(folder)")
        }
        
        return searchDirectory.appendingPathComponent(folder)
    }
    
    private func createDirectiory(for namespace: Namespace) {
        
        let path = makePath(.cachesDirectory, namespace.name)
        
        do {
            try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            
        }
        catch {
            preconditionFailure("FileCache: Unable to create a directory with: \(namespace.name) at: \(path)")
        }
    }
    
    private func directoryExists(for namespace: Namespace) -> Bool {
        
        var isDirectory = ObjCBool(true)
        
        return fileManager.fileExists(atPath: namespaceDirectory.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    private func fileExists(for key: CacheKey) -> Bool {
        return fileManager.fileExists(atPath: namespaceDirectory.path)
    }
    
    private func filePath(for key: CacheKey) -> URL {
        return namespaceDirectory.appendingPathComponent(key, isDirectory: false)
    }
    
}

