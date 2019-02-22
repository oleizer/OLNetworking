import struct Foundation.URL
import Moya

public protocol SugarTargetType: TargetType {
    typealias RoutePath = Route
    
    var url: URL { get }
    var route: Route { get }
    var parameters: Parameters? { get }
    var error: NSError? { get }
}

public extension SugarTargetType {
    public var url: URL {
        return self.defaultURL
    }
    
    var defaultURL: URL {
        return self.path.isEmpty ? self.baseURL : self.baseURL.appendingPathComponent(self.path)
    }
    
    public var path: String {
        return self.route.path
    }
    
    public var method: Moya.Method {
        return self.route.method
    }
    
    public var task: Task {
        guard let parameters = self.parameters else { return .requestPlain }
        return .requestParameters(parameters: parameters.values, encoding: parameters.encoding)
    }
    public var error: NSError? {
        return NSError()
    }
}
