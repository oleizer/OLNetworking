//
//  NetworkLogger.swift
//  Network
//
//  Created by Олег Лейзер on 19/02/2019.
//  Copyright © 2019 Олег Лейзер. All rights reserved.
//

import Moya
import Result

class NetworkLogger: PluginType {
    typealias Comparison = (TargetType) -> Bool
    
    let whitelist: Comparison
    let blacklist: Comparison
    
    init(whitelist: @escaping Comparison = { _ -> Bool in return true }, blacklist: @escaping Comparison = { _ -> Bool in  return true }) {
        self.whitelist = whitelist
        self.blacklist = blacklist
    }
    func willSend(_ request: RequestType, target: TargetType) {
        // If the target is in the blacklist, don't log it.
        
        guard blacklist(target) == false else { return }
        print("Sending request: \(request.request?.url?.absoluteString ?? String())")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        // If the target is in the blacklist, don't log it.
        guard blacklist(target) == false else { return }
        
        switch result {
        case .success(let response):
            if 200..<400 ~= (response.statusCode ) && whitelist(target) == false {
                // If the status code is OK, and if it's not in our whitelist, then don't worry about logging its response body.
                print("Received response(\(response.statusCode )) from \(response.response?.url?.absoluteString ?? String()).")
            }
        case .failure(let error):
            // Otherwise, log everything.
            print("Received networking error: \(error)")
        }
    }
}
