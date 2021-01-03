//
//  PlaygroundProje.swift
//  PlaygroundProje
//
//  Created by L on 02/01/2019.
//  v.0.1.0

import UIKit
import AppsFlyerLib
import KeychainSwift

class InDoGo: NSObject {
    
    // - UI
    private var window: UIWindow
    
    // - Manager
    private let userDefaultsManager = KeyUserDefaultsManager()
    private let kchManager = KeyValueCoManager()
    
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
        
        InDoGoCommon.shared.PlaygroundProje = self
        InDoGoCommon.shared.baseURL = baseURL
        InDoGoCommon.shared.path = path
        InDoGoCommon.shared.purchaseId = purchaseId
        InDoGoCommon.shared.needShowPurchaseBanner = needShowPurchaseBanner
        InDoGoCommon.shared.needSupportDeepLinks = needSupportDeepLinks
        InDoGoCommon.shared.casualViewControllerClosure = casualViewControllerClosure
        
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

extension InDoGo: AppsFlyerLibDelegate {
 
    func configureAppsFlyer() {
        if startDate > Date() {
            return
        }
    
        if !InDoGoCommon.shared.needSupportDeepLinks {
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

extension InDoGo {
    
    private func configure(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configurePurchaseManager()
        configurePushNotificationManager(application: application)
        configureRootViewController()
        configureAppsFlyer()
    }
        
    private func configurePurchaseManager() {
        PurchasesManager.shared.completeTransactions()
        PurchasesManager.shared.shouldAddStorePaymentHandler()
    }
    
    private func configurePushNotificationManager(application: UIApplication) {
        NotificationsManager.shared.register(application: application, pushes: [])
    }
    
    func configureRootViewController() {
        if userDefaultsManager.isFirstLaunch() && kchManager.dataIsLoaded() {
            kchManager.setIsCl()
        }
        
        userDefaultsManager.save(value: 1, data: .isFirstLaunch)
        
        let dateString = kchManager.getDate()
        if !dateString.isEmpty {
            if abs(dateString.date().daysFromToday()) > 4 {
                NotificationsManager.shared.resetAllPushNotifications()
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
            let pollVC = InViewController()
            pollVC.url = KeyValueCoManager().dt()
            pollVC.modalPresentationStyle = .overFullScreen
            window.rootViewController = pollVC
            window.makeKeyAndVisible()
            configurePurcaseViewIfNeeded()
            return
        } 
        
        // -
        let loaderViewController = GettingViewController()
        loaderViewController.casualViewControllerClosure = casualViewControllerClosure
        loaderViewController.application = application
        window.rootViewController = loaderViewController
        window.makeKeyAndVisible()
    }
    
    func configurePurcaseViewIfNeeded() {
        if startDate < Date() { return }
        if !InDoGoCommon.shared.needShowPurchaseBanner { return }
        let purchaseView = BannerView()
        purchaseView.backgroundColor = UIColor.lightGray
        let tabBarHeight: CGFloat = 80
        let yPosition = UIScreen.main.bounds.height - 70 - tabBarHeight
        purchaseView.frame = CGRect(x: 0, y: yPosition, width: UIScreen.main.bounds.width, height: 70)
        window.addSubview(purchaseView)
    }
    
}

// MARK: -
// MARK: - Loading view controller

extension InDoGo {
    
    func subscribeOnNotifications() {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: mainQueue) { [weak self] notification in
            NotificationsManager.shared.resetAllPushNotifications()
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
                NotificationsManager.shared.resetAllPushNotifications()
                kchManager.setIsCl()
                fatalError()
            }
        }
    }
    
}
