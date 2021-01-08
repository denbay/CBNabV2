//
//  DataProvider.swift
//  PlaygroundProje
//
//  Created by L on 02/01/2019.
//


var carrierName: String? {
    let networkInfo = CTTelephonyNetworkInfo()
    let carrier = networkInfo.subscriberCellularProvider
    return carrier?.carrierName
}

var currencyCode: String? {
    let locale = Locale.current
    return locale.currencyCode
}


import Moya
import CoreTelephony

enum DataProvider {
    
    case getData(params: [String: Any])
    
}

extension DataProvider: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getData:
            return URL(string: InDoGoCommon.shared.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .getData:
            return InDoGoCommon.shared.path
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

