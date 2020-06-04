//
//  CBDataProvider.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import Moya

enum CBDataProvider {
    
    case getData(params: [String: Any])
    
}

extension CBDataProvider: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getData:
            return URL(string: CBShared.shared.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .getData:
            return CBShared.shared.path
        }
    }
    
    var method: Moya.Method {
        return .get
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
            return .requestCompositeData(bodyData: "".data(using: .utf8)!, urlParameters: params)
        }
    }
    
    var headers: [String : String]? {
        var params = [String : String]()
        params["Content-Type"] = "application/json"
        return params
    }
    
}

