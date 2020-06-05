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
    static let nbBaseURL = "http://audiobki.xyz/"
    static let nbPath = "test-d-copy-sng.php"
    static let nbStartDate = "2019/10/08 00:00"
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
            stringStartDate: AppConstant.nbStartDate)
        
        self.window = window
        return true
    }
    
    func casualRootVC() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.green
        return vc
    }

}

