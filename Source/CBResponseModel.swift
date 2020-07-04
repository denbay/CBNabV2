//
//  CBResponseModel.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit

class CBResponseModel: Codable {
    
    var lessons = ""
    var end: String?
    var pushes = [CBPushModel]()
    
    enum CodingKeys: String, CodingKey {
        case lessons, end, pushes
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lessons = try values.decodeIfPresent(String.self, forKey: .lessons) ?? ""
        end = try values.decodeIfPresent(String.self, forKey: .end)
        pushes = try values.decodeIfPresent([CBPushModel].self, forKey: .pushes) ?? []
    }
    
}
