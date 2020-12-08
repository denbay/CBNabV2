//
//  CBShared.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit

class CBShared {
    
    // - Shared
    static let shared = CBShared()
    
    // - Data
    var cbNab: CBNab!
    var baseURL: String!
    var path: String!
    var purchaseId: String!
    var needShowCrashAfterScreen: Bool!
    var needSupportDeepLinks: Bool!
    var casualViewControllerClosure: ( () -> UIViewController)!

}
