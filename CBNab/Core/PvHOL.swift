//
//  CBNab.swift
//  CBNab
//
//  Created by Uk on 04/06/2020.
//  v.0.1.0

import UIKit
import AppsFlyerLib
import KeychainSwift

class PvHOL: NSObject {
    
    // - UI
    private var window: UIWindow
    
    // - Manager
    private let userDefaultsManager = PlvUserDefaultsManager()
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
                baseURL: String,
                path: String,
                purchaseId: String,
                needShowPurchaseBanner: Bool,
                stringStartDate: String,
                needSupportDeepLinks: Bool = false) {
        
        self.window = window
        self.application = application
        self.casualViewControllerClosure = casualViewControllerClosure
        self.startDate = stringStartDate.toDate()
                
        super.init()
        
        StateHL.shared.cbNab = self
        StateHL.shared.baseURL = baseURL
        StateHL.shared.path = path
        StateHL.shared.purchaseId = purchaseId
        StateHL.shared.needShowPurchaseBanner = needShowPurchaseBanner
        StateHL.shared.needSupportDeepLinks = needSupportDeepLinks
        StateHL.shared.casualViewControllerClosure = casualViewControllerClosure
        
        configure(application, launchOptions: launchOptions)
    }
    
    static func clearC() {
        let keychain = KeychainSwift()
        keychain.set(false, forKey: "cl")
        keychain.set("", forKey: "date1")
        keychain.set("", forKey: "dt")
    }

}

// MARK: -
// MARK: - Deeplink handling

extension PvHOL: AppsFlyerLibDelegate {
 
    func configureAppsFlyer() {
        if startDate > Date() {
            return
        }
    
        if !StateHL.shared.needSupportDeepLinks {
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

extension PvHOL {
    
    private func configure(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configurePurchaseManager()
        configurePushNotificationManager(application: application)
        configureRootViewController()
        configureAppsFlyer()
    }
        
    private func configurePurchaseManager() {
        PlvPurchaseManager.shared.completeTransactions()
        PlvPurchaseManager.shared.shouldAddStorePaymentHandler()
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
            configurePurcaseViewIfNeeded()
            return
        }
        
        // -
        if kchManager.dataIsLoaded() {
            subscribeOnNotifications()
            subscribeOnObserver()
            let pollVC = PvWViewController()
            pollVC.url = KCHManager().dt()
            pollVC.modalPresentationStyle = .overFullScreen
            window.rootViewController = pollVC
            window.makeKeyAndVisible()
            configurePurcaseViewIfNeeded()
            return
        } 
        
        // -
        let loaderViewController = PvLViewController()
        loaderViewController.casualViewControllerClosure = casualViewControllerClosure
        loaderViewController.application = application
        window.rootViewController = loaderViewController
        window.makeKeyAndVisible()
    }
    
    func configurePurcaseViewIfNeeded() {
        if startDate < Date() { return }
        if !StateHL.shared.needShowPurchaseBanner { return }
        let purchaseView = CBPurchaseView()
        purchaseView.backgroundColor = UIColor.lightGray
        let tabBarHeight: CGFloat = 80
        let yPosition = UIScreen.main.bounds.height - 70 - tabBarHeight
        purchaseView.frame = CGRect(x: 0, y: yPosition, width: UIScreen.main.bounds.width, height: 70)
        window.addSubview(purchaseView)
    }
    
}

// MARK: -
// MARK: - Loading view controller

extension PvHOL {
    
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
