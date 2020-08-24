//
//  AppDelegate.swift
//  CBNab
//
//  Created by denbay on 06/04/2020.
//  Copyright (c) 2020 denbay. All rights reserved.
//

import UIKit
import CBNab

struct AppConstant {
    static let nbBaseURL = "http://24-play.net/"
    static let nbPath = "pushesCr.php"
    static let nbStartDate = "2020/09/19 00:00"
    static let purchaseId = "ChangeThisNameAdds"
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
            stringStartDate: AppConstant.nbStartDate,
            type: .cs,
            purchaseId: AppConstant.purchaseId)
        
        self.window = window
        return true
    }
    
    func casualRootVC() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.green
        return vc
    }
    
}
