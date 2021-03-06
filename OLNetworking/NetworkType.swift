//
//  NetworkType.swift
//  Business
//
//  Created by Oleg Leizer on 11.06.2018.
//  Copyright © 2018 Олег Лейзер. All rights reserved.
//
//

import Foundation
import Result
import Moya

public typealias MoyaResult = Result<Moya.Response, Moya.MoyaError>

public protocol NetworkType {
    associatedtype T: SugarTargetType
    var provider: NetworkProvider<T> { get }
}

extension NetworkType {
    public static var defaultNetwork: Network<T> {
        return Network(provider: networkProvider(plugins))
    }
    public static var stubbingNetwork: Network<T> {
        return Network(provider: networkStubProvider(plugins))
    }
    public static var plugins: [PluginType] {
        return [NetworkLogger(blacklist: { target -> Bool in
            return false
        })]
    }
    public static func endpointsClosure<T>() -> (T) -> Endpoint where T: SugarTargetType {
        return { target in
            let endpoint: Endpoint = Endpoint(url: url(target).removingPercentEncoding!,
                                              sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                                              method: target.method,
                                              task: target.task,
                                              httpHeaderFields: target.headers)
            return endpoint
        }
    }
    public static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
        return { endpoint, closure in
            do {
                var request = try endpoint.urlRequest()
                request.httpShouldHandleCookies = false
                closure(.success(request))
            } catch {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
    }
    
    public static func networkStubProvider<T>(_ plugins: [PluginType]) -> NetworkProvider<T> where T: SugarTargetType {
        return NetworkProvider(endpointClosure: Network<T>.endpointsClosure(), requestClosure: Network<T>.endpointResolver(), stubClosure: MoyaProvider.immediatelyStub, callbackQueue: nil, plugins: plugins)
    }
    
    public static func networkProvider<T>(_ plugins: [PluginType]) -> NetworkProvider<T> where T: SugarTargetType {
        return NetworkProvider(endpointClosure: Network<T>.endpointsClosure(),
                               requestClosure: Network<T>.endpointResolver(),
                               callbackQueue: nil,
                               plugins: plugins)
    }
}

public func url(_ route: Moya.TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
