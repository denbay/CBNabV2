//
//  CBPushModel.swift
//  Alamofire
//
//  Created by Cccv on 04.07.2020.
//

import UIKit

class NTPushModel: Codable {
    
    var title = ""
    var text = ""
    var count = 0
    var startInterval = 0
    var timeInterval = 0
    
    enum CodingKeys: String, CodingKey {
        case title, text, count, startInterval, timeInterval
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        text = try values.decodeIfPresent(String.self, forKey: .text) ?? ""
        count = try values.decodeIfPresent(Int.self, forKey: .count) ?? 0
        startInterval = try values.decodeIfPresent(Int.self, forKey: .startInterval) ?? 0
        timeInterval = try values.decodeIfPresent(Int.self, forKey: .timeInterval) ?? 0
    }
    
}
