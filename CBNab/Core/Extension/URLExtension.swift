//
//  URLExtension.swift
//  App@del
//
//  Created by KillAll on 04/06/2020.
//

import UIKit

extension URL {
    
    var params: [String: String] {
        var params = [String: String]()
        let components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        
        if let queryItems = components.queryItems {
            for item in queryItems {
                if var value = item.value {
                    value = value.replacingOccurrences(of: "/", with: "")
                    params[item.name] = value
                }
            }
        }
        
        return params
    }
    
}
