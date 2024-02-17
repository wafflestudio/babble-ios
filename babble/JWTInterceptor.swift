//
//  JWTInterceptor.swift
//  babble
//
//  Created by Chaehyun Park on 2/13/24.
//

import Foundation
import Alamofire
class JWTInterceptor:RequestInterceptor{
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            urlRequest.headers.add(name: "Authorization", value: "Bearer " + accessToken)
            print(accessToken)
        }
        else {
            urlRequest.headers.add(name: "Authorization", value: "")
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        // Handle token refresh or direct user to login if retry limit is reached
        NotificationCenter.default.post(name: NSNotification.Name("AuthTokenExpired"), object: nil)
        completion(.doNotRetry)
    }
}

