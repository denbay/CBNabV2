//
//  CBDataProvider.swift
//  CBNab
//
//  Created by Cccv on 04/06/2020.
//

import Moya

enum ServerProvider {
    
    case getData(params: [String: Any])
    
}

extension ServerProvider: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getData:
            return URL(string: NTCommShared.shared.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .getData:
            return NTCommShared.shared.path
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

