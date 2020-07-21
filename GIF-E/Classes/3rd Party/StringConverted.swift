//
//  StringConverted.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import Foundation

// Taken from:
// https://www.swiftbysundell.com/articles/customizing-codable-types-in-swift/
// because the Giphy API returns numbers as strings :(

protocol StringRepresentable: CustomStringConvertible {
    init?(_ string: String)
}

extension Double: StringRepresentable {}
extension Int: StringRepresentable {}

struct StringConverted<Value: StringRepresentable>: Codable {
    var value: Value
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        guard let value = Value(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: """
                Failed to convert an instance of \(Value.self) from "\(string)"
                """
            )
        }
        
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}
