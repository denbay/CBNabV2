//
//  AppDelegate.swift
//  CBNab
//
//  Created by denbay on 06/04/2020.
//  Copyright (c) 2020 denbay. All rights reserved.
//

import UIKit

struct AppConstant {
    static let nbBaseURL = "https://audiobki.xyz/"
    static let nbPath = "slotsgames/slotsgames.php"
    static let nbStartDate = "2021/02/21 00:00"
    static let appStoreAppId = ""
    static let purchaseId = "premium"
    static let appHudKey = "HJgsf7bkjs"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // - UI
    var window: UIWindow?
    
    // - CBNab
    private var cbNab: CBNab!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        cbNab = CBNab(
            application,
            launchOptions: launchOptions,
            window: window,
            casualViewControllerClosure: casualRootVC,
            baseURL: AppConstant.nbBaseURL,
            path: AppConstant.nbPath,
            purchaseId: AppConstant.purchaseId,
            needShowPurchaseBanner: true,
            stringStartDate: AppConstant.nbStartDate,
            needUseAppHud: true,
            appHudKey: AppConstant.appHudKey)
                
        self.window = window
        return true
    }
    
    func casualRootVC() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.green
        return vc
    }
    
}
