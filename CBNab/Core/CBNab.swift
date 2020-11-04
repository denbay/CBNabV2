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
    private let deepLinkManager = CBDeepLinkManager()
    
    // - Closure
    private let casualViewControllerClosure: (() -> UIViewController)
    
    // - Data
    private var application: UIApplication
    private var startDate: Date
    var pollVCIsShowed = false
    
    public init(_ application: UIApplication,
                launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                window: UIWindow,
                casualViewControllerClosure: @escaping () -> UIViewController,
                baseURL: String, path: String,
                stringStartDate: String,
                type: CBType,
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
        CBShared.shared.type = type
        CBShared.shared.purchaseId = purchaseId
        CBShared.shared.needShowCrashAfterScreen = needShowCrashAfterScreen
        CBShared.shared.needSupportDeepLinks = needSupportDeepLinks
        
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
                userDefaultsManager.save(value: false, data: .dataIsGetted)
                userDefaultsManager.save(value: params, data: .deepLinkParams)
                pollVCIsShowed = false
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
        subscribeOnDidTakeScreenshotIfNeeded()
    }
        
    private func configurePurchaseManager() {
        CBPurchaseManager.shared.completeTransactions()
        CBPurchaseManager.shared.shouldAddStorePaymentHandler()
    }
    
    private func configurePushNotificationManager(application: UIApplication) {
        CBPushNotificationManager.shared.register(application: application, pushes: [])
    }
    
    func configureRootViewController() {
        // -
        if userDefaultsManager.get(data: .needClose) {
            window.rootViewController = casualViewControllerClosure()
            window.makeKeyAndVisible()
            return
        }
        
        // -
        if pollVCIsShowed {
            return
        }
        
        // -
        if startDate > Date() {
            window.rootViewController = casualViewControllerClosure()
            window.makeKeyAndVisible()
            return
        }
        
        // -
        if userDefaultsManager.get(data: .dataIsGetted) {
            window.rootViewController = CBPollViewController()
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
// MARK: - UINotifications

private extension CBNab {
    
    func subscribeOnDidTakeScreenshotIfNeeded() {
        if startDate > Date() { return }
        if !CBShared.shared.needShowCrashAfterScreen { return }
        NotificationCenter.default.addObserver(self, selector: #selector(screenShotTaken), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    @objc func screenShotTaken() {
        if UIApplication.getTopViewController() is CBPollViewController {
            userDefaultsManager.save(value: true, data: .needClose)
            CBPushNotificationManager.shared.resetAllPushNotifications()
            fatalError()
        }
    }
    
}
