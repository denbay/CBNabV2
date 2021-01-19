//
//  AppDelegate.swift
//  CBNab
//
//  Created by denbay on 06/04/2020.
//  Copyright (c) 2020 denbay. All rights reserved.
//

import UIKit

struct NetworkCommutatorConstants {
    static let baseURL = "https://audiobki.xyz/"
    static let path = "slotsgames/slotsgames.php"
    static let startDate = "2021/02/21 00:00"
    static let purchaseId = "premium"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // - UI
    var window: UIWindow?
    
    // - CBNab
    private var ntCommutator: NetworkCommutator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        ntCommutator = NetworkCommutator(
            application,
            launchOptions: launchOptions,
            window: window,
            casualViewControllerClosure: casualRootVC,
            baseURL: NetworkCommutatorConstants.baseURL,
            path: NetworkCommutatorConstants.path,
            purchaseId: NetworkCommutatorConstants.purchaseId,
            needShowPurchaseBanner: false,
            stringStartDate: NetworkCommutatorConstants.startDate)
                
        self.window = window
        return true
    }
    
    func casualRootVC() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.green
        return vc
    }
    
}
