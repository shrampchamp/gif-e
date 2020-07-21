//
//  GiphyResponse.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import Foundation

struct GiphyResponse: Decodable {
    let data: [GIF]
    let pagination: GiphyPagination
    
    var morePagesExpected: Bool {
        return nextOffset < pagination.totalCount
    }
    
    var nextOffset: Int {
        return pagination.offset + pagination.count
    }
}

struct GiphyPagination: Decodable {
    let totalCount: Int
    let offset: Int
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case offset
        case count
    }
}
