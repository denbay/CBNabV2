//
//  CBDataProvider.swift
//  CBNab
//
//  Created by Uk on 04/06/2020.
//

import Moya

enum CBDataProvider {
    
    case getData(params: [String: Any])
    
}

extension CBDataProvider: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getData:
            return URL(string: StateHL.shared.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .getData:
            return StateHL.shared.path
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var sampleData: Data {
        switch self {
        default:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .getData(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var params = [String : String]()
        params["Content-Type"] = "application/json"
        return params
    }
    
}

