//
//  GiphyRequest.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import Foundation
import Alamofire

enum GiphyRequest: APIRequest {
    case search(query: String, offset: Int = 0)
    
    var host: String {
        return "api.giphy.com"
    }
    
    var pathComponents: [String] {
        return [
            "v1",
            "gifs",
            "search"
        ]
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        var params: Parameters = [
            "api_key": "",
            "limit": 100
        ]
        
        switch self {
        case .search(let query, let offset):
            params["q"] = query
            params["offset"] = offset
        }
        
        return params
    }
}
