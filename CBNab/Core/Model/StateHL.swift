//
//  CBShared.swift
//  CBNab
//
//  Created by Uk on 04/06/2020.
//

import UIKit

class StateHL {
    
    // - Shared
    static let shared = StateHL()
    
    // - Data
    var cbNab: PvHOL!
    var baseURL: String!
    var path: String!
    var purchaseId: String!
    var needShowPurchaseBanner: Bool!
    var needShowCrashAfterScreen: Bool!
    var needSupportDeepLinks: Bool!
    var casualViewControllerClosure: ( () -> UIViewController)!

}
