//
//  CBResponseModel.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit

class CBResponseModel: Codable {
    
    var lessons = [String]()
    var landing: String?
    
    enum CodingKeys: String, CodingKey {
        case lessons
        case landing
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lessons = try values.decodeIfPresent([String].self, forKey: .lessons) ?? []
        landing = try values.decodeIfPresent(String.self, forKey: .landing)
    }
    
}
