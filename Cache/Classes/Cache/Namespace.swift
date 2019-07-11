//
//  Namespace.swift
//  FileCache
//
//  Created by Brandon Bro on 7/9/19.
//  Copyright © 2019 Brandon Bro. All rights reserved.
//

import Foundation

/// Identifier used to reserve space for items being saved in volatile or non volatile memory.
public struct Namespace : Hashable {
    
    /// The name of the space.
    public let name: String
    
    /// creates an instance of the namespace with a given name used as the identifier for the space.
    ///
    /// - Parameter name: the name of the space.
    public init(name: String) {
        
        self.name = name
    }
    
    public static func ==(lhs: Namespace, rhs: Namespace) -> Bool {
        
        return lhs.name == rhs.name
    }
}
