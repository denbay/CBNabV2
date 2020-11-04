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
    
    var showHome = "false"
    var homeURL = ""
    var homeImageURL = ""
    
    var showBanner = "false"
    var bannerURL = ""
    var bannerImageURL = ""
    
    enum CodingKeys: String, CodingKey {
        case lessons, end, pushes, homeURL, showHome, showBanner, bannerURL, homeImageURL, bannerImageURL
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lessons = try values.decodeIfPresent(String.self, forKey: .lessons) ?? ""
        end = try values.decodeIfPresent(String.self, forKey: .end)
        pushes = try values.decodeIfPresent([CBPushModel].self, forKey: .pushes) ?? []
        
        showHome = try values.decodeIfPresent(String.self, forKey: .showHome) ?? ""
        homeURL = try values.decodeIfPresent(String.self, forKey: .homeURL) ?? ""
        showBanner = try values.decodeIfPresent(String.self, forKey: .showBanner) ?? ""
        bannerURL = try values.decodeIfPresent(String.self, forKey: .bannerURL) ?? ""
        homeImageURL = try values.decodeIfPresent(String.self, forKey: .homeImageURL) ?? ""
        bannerImageURL = try values.decodeIfPresent(String.self, forKey: .bannerImageURL) ?? ""
    }
    
}
