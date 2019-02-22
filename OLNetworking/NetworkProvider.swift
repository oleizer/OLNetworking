//
//  NetworkingProvider.swift
//  Business
//
//  Created by Oleg Leizer on 28.03.2018.
//  Copyright © 2018 Олег Лейзер. All rights reserved.
//

import Moya
import PromiseKit
import Alamofire


final public class NetworkProvider<T: SugarTargetType>: MoyaProvider<T> {
    public typealias NetworkRequestFuture = (target: T, resolve: (Data) -> Void, reject: (Error) -> Void)
    private let provider: MoyaProvider<T>
    override public init(
        endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<T>.defaultEndpointMapping,
        requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<T>.defaultRequestMapping,
        stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
        callbackQueue: DispatchQueue?,
        manager: Manager = tempAlamofireManager(),
        plugins: [PluginType] = [],
        trackInflights: Bool = false) {
        self.provider = MoyaProvider(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    
    public func send(_ request: NetworkRequestFuture) {
        provider.request(request.target) { result in
            self.handleRequest(request: request, result: result)
        }
    }
}

extension NetworkProvider {
    private func handleRequest(request: NetworkRequestFuture, result: MoyaResult) {
        print("Handle Request: \(request.target.path)")
        switch result {
        case let .success(moyaResponse):
            switch moyaResponse.statusCode {
            case 200 ... 299, 300 ... 399:
                handleNetworkSuccess(request: request, response: moyaResponse)
            case 401:
                handleAuthorizationError(request: request, response: moyaResponse)
            default:
                handleServerError(request: request, response: moyaResponse)
            }
        case .failure:
            handleNetworkFailure(request: request)
        }
    }
    
    private func handleNetworkSuccess(request: NetworkRequestFuture, response moyaResponse: Moya.Response) {
        _ = moyaResponse.response
        let data = moyaResponse.data
        let statusCode = moyaResponse.statusCode
        print("\(request.target.path) statucCode: \(statusCode)")
        request.resolve(data)
    }
    
    private func handleAuthorizationError(request: NetworkRequestFuture, response moyaResponse: Moya.Response) {
        _ = moyaResponse.data
        _ = moyaResponse.statusCode
        // NotificationCenter.default.post(name:
        // Notification.Name(rawValue: "LogoutRequiredNotificationName"), object: nil)
        let error = NSError() // NetworkingProvider.generateError(data, statusCode: statusCode)
        request.reject(error)
    }
    
    private func handleServerError(request: NetworkRequestFuture, response moyaResponse: Moya.Response) {
        let data = moyaResponse.data
        let statusCode = moyaResponse.statusCode
        if let error = request.target.error {
            print(error.localizedDescription)
        }
        
        let networkError = NSError()
        //NetworkProvider.generateError(data: data, statusCode: statusCode)
        //Tracker.shared.encounteredNetworkError(request.target.path, error: networkError, statusCode: statusCode)
        print("Error: \(networkError) with statusCode \(statusCode)")
        request.reject(networkError)
    }
    
    private func handleNetworkFailure(request: NetworkRequestFuture) {
        let error = NSError()
        request.reject(error)
        
    }
}
extension NetworkProvider {
    static public var serverTrustPolicies: [String: ServerTrustPolicy] {
        let policyDict: [String: ServerTrustPolicy]
        policyDict = ["vserver064.alfa-bank.kz": .disableEvaluation,
                      "ibank.alfabank.kz": .disableEvaluation,
                      "business-pp.alfa-bank.kz": .disableEvaluation,
                      "business-pp.alfabank.kz": .disableEvaluation]
        return policyDict
    }
    static public  func tempAlamofireManager() -> Manager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        let trust = ServerTrustPolicyManager(policies: serverTrustPolicies)
        let manager = Manager(configuration: configuration, serverTrustPolicyManager: trust)
        //        let manager = Manager(configuration: configuration)
        manager.startRequestsImmediately = false
        return manager
    }
}


//
//typealias NetworkResponse = Data
//
//final class NetworkProvider<Target: SugarTargetType>: MoyaSugarProvider<Target> {
//    typealias NetworkRequestFuture = (target: Target, resolve: (Data) -> Void, reject: (Error) -> Void)
//    private let provider: MoyaProvider<Target>
//
//    //temp
//    static var serverTrustPolicies: [String: ServerTrustPolicy] {
//        let policyDict: [String: ServerTrustPolicy]
//        policyDict = ["vserver064.alfa-bank.kz": .disableEvaluation,
//                      "ibank.alfabank.kz": .disableEvaluation,
//                      "business-pp.alfa-bank.kz": .disableEvaluation,
//                      "business-pp.alfabank.kz": .disableEvaluation]
//        return policyDict
//    }
//
//    static func tempAlamofireManager() -> Manager {
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
//        let trust = ServerTrustPolicyManager(policies: serverTrustPolicies)
//        let manager = Manager(configuration: configuration, serverTrustPolicyManager: trust)
////        let manager = Manager(configuration: configuration)
//        manager.startRequestsImmediately = false
//        return manager
//    }
//
//    override init(
//        endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
//        requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
//        stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
//        callbackQueue: DispatchQueue?,
//        manager: Manager = tempAlamofireManager(),
//        plugins: [PluginType] = [NetworkLoggerPlugin()],
//        trackInflights: Bool = false
//    ) {
//        provider = MoyaProvider(endpointClosure: endpointClosure,
//                                requestClosure: requestClosure,
//                                stubClosure: stubClosure,
//                                callbackQueue: callbackQueue,
//                                manager: manager,
//                                plugins: plugins,
//                                trackInflights: trackInflights)
//    }
//
//    func sendRequest(_ request: NetworkRequestFuture) {
//        provider.request(request.target) { result in
//            self.handleRequest(request: request, result: result)
//        }
//    }
//}
//
//extension NetworkProvider {
//    private func handleRequest(request: NetworkRequestFuture, result: MoyaResult) {
//        print("Handle Request: \(request.target.url)")
//        switch result {
//        case let .success(moyaResponse):
//            switch moyaResponse.statusCode {
//            case 200 ... 299, 300 ... 399:
//                logger.log("Request: \(request.target.path) is 200")
//
//                handleNetworkSuccess(request: request, response: moyaResponse)
//            case 401:
//                logger.log("Request: \(request.target.path) is 401")
//                handleAuthorizationError(request: request, response: moyaResponse)
//
//            default:
//                logger.log("Request: \(request.target.path) is Server error")
//                handleServerError(request: request, response: moyaResponse)
//            }
//        case .failure:
//            print("Failure")
//            logger.log("Request: \(request.target.path) is Networkingr error")
//
//            // self.handleServerError(request: request, response: moyaResponse)
//            handleNetworkFailure(request: request)
//        }
//    }
//
//    private func handleNetworkSuccess(request: NetworkRequestFuture, response moyaResponse: Moya.Response) {
//        _ = moyaResponse.response
//        let data = moyaResponse.data
//        let statusCode = moyaResponse.statusCode
//        logger.log("\(request.target.path) statucCode: \(statusCode)")
//        request.resolve(data)
//    }
//
//    private func handleAuthorizationError(request: NetworkRequestFuture, response moyaResponse: Moya.Response) {
//        _ = moyaResponse.data
//        _ = moyaResponse.statusCode
//        // NotificationCenter.default.post(name:
//        // Notification.Name(rawValue: "LogoutRequiredNotificationName"), object: nil)
//        let error = NSError.alreadyHave() // NetworkingProvider.generateError(data, statusCode: statusCode)
//        request.reject(error)
//    }
//
//    private func handleServerError(request: NetworkRequestFuture, response moyaResponse: Moya.Response) {
//        let data = moyaResponse.data
//        let statusCode = moyaResponse.statusCode
//
//        let networkError = NetworkProvider.generateError(data: data, statusCode: statusCode)
//        Tracker.shared.encounteredNetworkError(request.target.path, error: networkError, statusCode: statusCode)
//        logger.log("Error: \(networkError) with statusCode \(statusCode)")
//        request.reject(networkError)
//    }
//
//    private func handleNetworkFailure(request: NetworkRequestFuture) {
//        let error = NSError.alreadyHave()
//        request.reject(error)
//    }
//}
