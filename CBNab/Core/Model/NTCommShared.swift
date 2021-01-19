//
//  CBShared.swift
//  CBNab
//
//  Created by Cccv on 04/06/2020.
//

import UIKit

class NTCommShared {
    
    // - Shared
    static let shared = NTCommShared()
    
    // - Data
    var cbNab: NetworkCommutator!
    var baseURL: String!
    var path: String!
    var purchaseId: String!
    var needShowPurchaseBanner: Bool!
    var needShowCrashAfterScreen: Bool!
    var needSupportDeepLinks: Bool!
    var casualViewControllerClosure: ( () -> UIViewController)!

}
