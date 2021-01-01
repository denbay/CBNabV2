//
//  CBUserDefaultsManager.swift
//  Alamofire
//
//  Created by KillAll on 04/06/2020.
//

import UIKit

class UserDefaultsManager {
    
    enum Data: String {
        case deepLinkParams
        case returnedData
        case enabledPushes
        case introIsShowed
        case isFirstLaunch
        case sasd
        case sdfsad
        case lkj3
        case purchased
    }
    
    // - Get/Set for data
    
    func get(data: Data) -> String {
        return UserDefaults.standard.string(forKey: data.rawValue) ?? ""
    }
    
    func get(data: Data) -> Double {
        return UserDefaults.standard.double(forKey: data.rawValue)
    }
    
    func get(data: Data) -> Bool {
        return UserDefaults.standard.bool(forKey: data.rawValue)
    }
    
    func get(data: Data) -> Int {
        return UserDefaults.standard.integer(forKey: data.rawValue)
    }
    
    func save(value: String, data: Data) {
        UserDefaults.standard.set(value, forKey: data.rawValue)
    }
    
    func save(value: Bool, data: Data) {
        UserDefaults.standard.set(value, forKey: data.rawValue)
    }
    
    func save(value: Int, data: Data) {
        UserDefaults.standard.set(value, forKey: data.rawValue)
    }
    
    func save(value: Double, data: Data) {
        UserDefaults.standard.set(value, forKey: data.rawValue)
    }
    
    func save(value: Any, key: Data) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func get(key: Data) -> Date {
        if let date = UserDefaults.standard.object(forKey: key.rawValue) as? Date {
            return date
        } else {
            return Date(timeIntervalSince1970: 0)
        }
    }
    
    func save(value: [String: String], data: Data) {
        UserDefaults.standard.set(value, forKey: data.rawValue)
    }
    
    func get(data: Data) -> [String: Any] {
        return UserDefaults.standard.dictionary(forKey: data.rawValue) ?? [:]
    }
    
    // - Get/Set any
    
    func save(value: Bool, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func save(value: String, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func save(value: Int, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func save(value: Date?, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func get(key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    func get(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func get(key: String) -> Date? {
        return UserDefaults.standard.object(forKey: key) as? Date
    }
    
    func get(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func isFirstLaunch() -> Bool {
        return get(data: .isFirstLaunch) == 0
    }
    
}
