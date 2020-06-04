//
//  CBDeepLinkManager.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit

class CBDeepLinkManager {
    
    // - Manager
    private let userDefaultsManager = CBUserDefaultsManager()
    
    func handleFBDeeplink(url: URL) -> [String: String] {
        let params = url.params
        if let landing = params["landing"], landing != "CampaignName" {
            userDefaultsManager.save(value: params, data: .deepLinkParams)
        }
        
        return params
    }
    
    func handleDeepLink(params: [AnyHashable: Any]) -> [String: String] {
        var stringParams: [String: String] = [:]
        
        // - Dynamic params
        if let urlString = params["~referring_link"] as? String {
            if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "") {
                for (key, value) in url.params {
                    stringParams[key] = value
                }
            }
        }
        
        if let landing = params["landing"] as? String {
            stringParams["landing"] = landing
        }
        
        // - If apple search
        
        if let campaign = params["~campaign"] as? String {
            stringParams["landing"] = campaign
            stringParams["site_id"] = "AppleSearchAds"
        }
        
        if let campaign = params["~last_attributed_touch_data_tilde_campaign"] as? String {
            stringParams["landing"] = campaign
            stringParams["site_id"] = "AppleSearchAds"
        }
        
        if let campaign = params["last_attributed_touch_data_tilde_campaign"] as? String {
            stringParams["landing"] = campaign
            stringParams["site_id"] = "AppleSearchAds"
        }
        
        /* Createive id */
        
        if let adGroupName = params["~ad_set_name"] as? String {
            stringParams["creative_id"] = adGroupName
        }
        
        if let adGroupName = params["~last_attributed_touch_data_tilde_ad_set_name"] as? String {
            stringParams["creative_id"] = adGroupName
        }
        
        if let adGroupName = params["last_attributed_touch_data_tilde_ad_set_name"] as? String {
            stringParams["creative_id"] = adGroupName
        }
        
        for (key, value) in params {
            guard let key = key as? String else { continue }
            guard let value = value as? String else { continue }
            
            if let first = key.first {
                let firstString = String(first)
                
                if firstString != "~" && firstString != "&" && firstString != "$" {
                    stringParams[key] = value
                }
            }
        }
        
        if stringParams["landing"] != nil, stringParams["landing"] != "CampaignName" {
            userDefaultsManager.save(value: stringParams, data: .deepLinkParams)
        } else {
            return [:]
        }
        
        return stringParams
    }
    
}

