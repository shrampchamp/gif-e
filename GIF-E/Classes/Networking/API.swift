//
//  API.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import Foundation
import Alamofire

class API {
    typealias Completion<T> = (Result<T>) -> Void
    
    let sessionManager: SessionManager
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    init(sessionManager: SessionManager = .default){
        self.sessionManager = sessionManager
    }
    
    @discardableResult
    func request<T: Decodable>(_ request: APIRequest, expectedType: T.Type, completion: @escaping Completion<T>) -> DataRequest {
        let request = sessionManager.request(
            request,
            method: request.httpMethod,
            parameters: request.parameters,
            encoding: request.parameterEncoding,
            headers: headers
        ).validate().responseData { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        return request
    }
}
