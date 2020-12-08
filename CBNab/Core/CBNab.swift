//
//  CBNab.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//  v.0.1.0

import UIKit
import AppsFlyerLib

class CBNab: NSObject {
    
    // - UI
    private var window: UIWindow
    
    // - Manager
    private let userDefaultsManager = CBUserDefaultsManager()
    private let kchManager = KCHManager()
    
    // - Closure
    private let casualViewControllerClosure: (() -> UIViewController)
    
    // - Data
    private var application: UIApplication
    private var startDate: Date
    
    public init(_ application: UIApplication,
                launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                window: UIWindow,
                casualViewControllerClosure: @escaping () -> UIViewController,
                baseURL: String, path: String,
                stringStartDate: String,
                purchaseId: String,
                needShowCrashAfterScreen: Bool = false,
                needSupportDeepLinks: Bool = false) {
        
        self.window = window
        self.application = application
        self.casualViewControllerClosure = casualViewControllerClosure
        self.startDate = stringStartDate.toDate()
                
        super.init()
        
        CBShared.shared.cbNab = self
        CBShared.shared.baseURL = baseURL
        CBShared.shared.path = path
        CBShared.shared.purchaseId = purchaseId
        CBShared.shared.needShowCrashAfterScreen = needShowCrashAfterScreen
        CBShared.shared.needSupportDeepLinks = needSupportDeepLinks
        CBShared.shared.casualViewControllerClosure = casualViewControllerClosure
        
        configure(application, launchOptions: launchOptions)
    }

}

// MARK: -
// MARK: - Deeplink handling

extension CBNab: AppsFlyerLibDelegate {
 
    func configureAppsFlyer() {
        if startDate > Date() {
            return
        }
    
        if !CBShared.shared.needSupportDeepLinks {
            return
        }
        
        AppsFlyerLib.shared().appsFlyerDevKey = "RBS5RkbZkGEpbPLNMek5D7"
        AppsFlyerLib.shared().appleAppID = AppConstant.appStoreAppId
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().start()
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        if startDate > Date() {
            return
        }
        
        if let is_first_launch = conversionInfo["is_first_launch"] as? Bool, is_first_launch {
            if true {
                var params = [String: String]()
                params["campaign"] = (conversionInfo["сampaign"] as? String) ?? ""
                params["appsflyerId"] = (conversionInfo["appsflyer_id"] as? String) ?? ""
                userDefaultsManager.save(value: params, data: .deepLinkParams)
                configureRootViewController()
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {}
    
}

// MARK: -
// MARK: - Configure

extension CBNab {
    
    private func configure(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configurePurchaseManager()
        configurePushNotificationManager(application: application)
        configureRootViewController()
        configureAppsFlyer()
    }
        
    private func configurePurchaseManager() {
        CBPurchaseManager.shared.completeTransactions()
        CBPurchaseManager.shared.shouldAddStorePaymentHandler()
    }
    
    private func configurePushNotificationManager(application: UIApplication) {
        CBPushNotificationManager.shared.register(application: application, pushes: [])
    }
    
    func configureRootViewController() {
        if userDefaultsManager.isFirstLaunch() && kchManager.dataIsLoaded() {
            kchManager.setIsCl()
        }
        
        userDefaultsManager.save(value: 1, data: .isFirstLaunch)
        
        let dateString = kchManager.getDate()
        if !dateString.isEmpty {
            if abs(dateString.date().daysFromToday()) > 4 {
                CBPushNotificationManager.shared.resetAllPushNotifications()
                kchManager.setIsCl()
            }
        }
                
        // -
        if startDate > Date() || kchManager.isCl() {
            window.rootViewController = casualViewControllerClosure()
            window.makeKeyAndVisible()
            return
        }
        
        // -
        if kchManager.dataIsLoaded() {
            subscribeOnNotifications()
            subscribeOnObserver()
            let pollVC = CBPollViewController()
            pollVC.url = KCHManager().dt()
            pollVC.modalPresentationStyle = .overFullScreen
            window.rootViewController = pollVC
            window.makeKeyAndVisible()
            return
        } 
        
        // -
        let loaderViewController = CBLoaderViewController()
        loaderViewController.casualViewControllerClosure = casualViewControllerClosure
        loaderViewController.application = application
        window.rootViewController = loaderViewController
        window.makeKeyAndVisible()
    }
    
}

// MARK: -
// MARK: - Loading view controller

extension CBNab {
    
    func subscribeOnNotifications() {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: mainQueue) { [weak self] notification in
            CBPushNotificationManager.shared.resetAllPushNotifications()
            self?.kchManager.setIsCl()
            fatalError()
        }
    }
    
    func subscribeOnObserver() {
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "captured") {
            let isCaptured = UIScreen.main.isCaptured
            if isCaptured {
                CBPushNotificationManager.shared.resetAllPushNotifications()
                kchManager.setIsCl()
                fatalError()
            }
        }
    }
    
}
