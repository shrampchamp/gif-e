//
//  GIF.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import Foundation

struct GIF: Decodable {
    let title: String?
    let images: Images
}

struct Images: Decodable {
    let fixedWidth: Image
    let original: Image
    
    enum CodingKeys: String, CodingKey {
        case fixedWidth = "fixed_width"
        case original = "original"
    }
}

struct Image: Decodable {
    let url: URL
    let width: StringConverted<Double>
    let height: StringConverted<Double>
    let size: StringConverted<Int>
}
