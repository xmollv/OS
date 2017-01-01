//
//  NetworkManager.swift
//  OS
//
//  Created by Xavi Moll on 26/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import Foundation

protocol NetworkManagerClient {
    func set(networkManager: NetworkManager)
}

class NetworkManager {
    
    // This is just an alias to make it more readable
    typealias CompletionHandlerType = (Result) -> Void
    
    // If we return an enum, we can switch over it and it's really clear for the reader
    enum Result {
        case success(Any?)
        case failure(Error)
    }
    
    enum XMVError: Error {
        case malformedUrl
        case noData
        case parsingJson
        case unknown
        
        var errorDescription: String {
            switch self {
            case .malformedUrl:
                return "The URL was malformed."
            case .noData:
                return "There was no data on the server response."
            case .parsingJson:
                return "Error parsing the JSON file."
            case .unknown:
                return "Unkown error"
            }
        }
    }
    
    // This is a default implementation of a method to fetch data from any given URL. We should improve it to accept different
    // HTTP methods, change the timeots, allow to send body parameters...
    func fetchDataFrom(serverUrl: String, headers: [String:String]?, then completionHandler: @escaping CompletionHandlerType) {
        if let url = URL(string: serverUrl) {
            
            let request = NSMutableURLRequest(url: url)
            
            if let headers = headers {
                for elem in headers {
                    request.setValue(elem.value, forHTTPHeaderField: elem.key)
                }
            }
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                guard error == nil else {
                    if let error = error {
                        completionHandler(Result.failure(error))
                    } else {
                        completionHandler(Result.failure(XMVError.unknown))
                    }
                    return
                }
                guard let data = data else {
                    completionHandler(Result.failure(XMVError.noData))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    completionHandler(Result.success(json))
                } catch {
                    completionHandler(Result.failure(XMVError.parsingJson))
                }
            }
            task.resume()
        } else {
            completionHandler(Result.failure(XMVError.malformedUrl))
        }
    }
}


