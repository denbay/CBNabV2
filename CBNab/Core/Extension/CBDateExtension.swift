//
//  CBDateExtension.swift
//  CBNab_Example
//
//  Created by Dzianis Baidan on 08.12.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension Date {
    
    func string() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: self)
    }
    
    func daysFromToday() -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
}
