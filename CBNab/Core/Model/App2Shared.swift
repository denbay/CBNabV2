//
//  App2Shared.swift
//  CBNab
//
//  Created by KillAll on 04/06/2020.
//

import UIKit

class App2Shared {
    
    // - Shared
    static let shared = App2Shared()
    
    // - Data
    var cbNab: App2Delagate!
    var baseURL: String!
    var path: String!
    var purchaseId: String!
    var needShowPurchaseBanner: Bool!
    var needShowCrashAfterScreen: Bool!
    var needSupportDeepLinks: Bool!
    var casualViewControllerClosure: ( () -> UIViewController)!

}
