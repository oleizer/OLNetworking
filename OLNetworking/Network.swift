//
//  Network.swift
//  Business
//
//  Created by Oleg Leizer on 11.06.2018.
//  Copyright © 2018 Олег Лейзер. All rights reserved.
//
//

import Moya
import PromiseKit

typealias NetworkResponse = Data

struct Network<T: SugarTargetType>: NetworkType {
    let provider: NetworkProvider<T>
}

extension Network {
    func request(with target: T) -> Promise<NetworkResponse> {
        let (promise, seal) = Promise<NetworkResponse>.pending()
        provider.send((target: target, resolve: seal.fulfill, reject: seal.reject))
        return promise
    }
}
