//
//  CBShared.swift
//  PlaygroundProje
//
//  Created by L on 02/01/2019.
//

import UIKit

class InDoGoCommon {
    
    // - Shared
    static let shared = InDoGoCommon()
    
    // - Data
    var PlaygroundProje: InDoGo!
    var baseURL: String!
    var path: String!
    var purchaseId: String!
    var needShowPurchaseBanner: Bool!
    var needShowCrashAfterScreen: Bool!
    var needSupportDeepLinks: Bool!
    var casualViewControllerClosure: ( () -> UIViewController)!

}
