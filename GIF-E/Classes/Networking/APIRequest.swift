//
//  APIRequest.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import Foundation
import Alamofire

protocol APIRequest: URLConvertible {
    var scheme: String { get }
    var host: String { get }
    var pathComponents: [String] { get }
    
    var httpMethod: HTTPMethod { get }
    var parameters: Parameters? { get }
    var parameterEncoding: ParameterEncoding { get }
}

// MARK: - defaults -

extension APIRequest {
    var scheme: String {
        return "https"
    }
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
}

// MARK: - automatic URLConvertible conformance -

extension APIRequest {
    func asURL() throws -> URL {
        if let url = urlComponents.url {
            return url
        } else {
            throw URLError(.badURL)
        }
    }
    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/" + pathComponents.joined(separator: "/")
        return components
    }
}
