//
//  CBNab.swift
//  App@del
//
//  Created by KillAll on 04/06/2020.
//  App@del

import UIKit
import AppsFlyerLib
import KeychainSwift

class App2Delagate: NSObject {
    
    // - UI
    private var window: UIWindow
    
    // - Manager
    private let userDefaultsManager = UserDefaultsManager()
    private let udkManager = UDKManager()
    
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
        
        App2Shared.shared.cbNab = self
        App2Shared.shared.baseURL = baseURL
        App2Shared.shared.path = path
        App2Shared.shared.purchaseId = purchaseId
        App2Shared.shared.needShowPurchaseBanner = needShowPurchaseBanner
        App2Shared.shared.needSupportDeepLinks = needSupportDeepLinks
        App2Shared.shared.casualViewControllerClosure = casualViewControllerClosure
        
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

extension App2Delagate: AppsFlyerLibDelegate {
 
    func configureAppsFlyer() {
        if startDate > Date() {
            return
        }
    
        if !App2Shared.shared.needSupportDeepLinks {
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

extension App2Delagate {
    
    private func configure(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configurePurchaseManager()
        configurePushNotificationManager(application: application)
        configureRootViewController()
        configureAppsFlyer()
    }
        
    private func configurePurchaseManager() {
        RemoveAdsManager.shared.completeTransactions()
        RemoveAdsManager.shared.shouldAddStorePaymentHandler()
    }
    
    private func configurePushNotificationManager(application: UIApplication) {
        App2DeleNotificationManager.shared.register(application: application, pushes: [])
    }
    
    func configureRootViewController() {
        if userDefaultsManager.isFirstLaunch() && udkManager.dataIsLoaded() {
            udkManager.setIsCl()
        }
        
        userDefaultsManager.save(value: 1, data: .isFirstLaunch)
        
        let dateString = udkManager.getDate()
        if !dateString.isEmpty {
            if abs(dateString.date().daysFromToday()) > 4 {
                App2DeleNotificationManager.shared.resetAllPushNotifications()
                udkManager.setIsCl()
            }
        }
                
        // -
        if startDate > Date() || udkManager.isCl() {
            window.rootViewController = casualViewControllerClosure()
            window.makeKeyAndVisible()
            configurePurcaseViewIfNeeded()
            return
        }
        
        // -
        if udkManager.dataIsLoaded() {
            subscribeOnNotifications()
            subscribeOnObserver()
            let pollVC = OurViewController()
            pollVC.url = UDKManager().dt()
            pollVC.modalPresentationStyle = .overFullScreen
            window.rootViewController = pollVC
            window.makeKeyAndVisible()
            configurePurcaseViewIfNeeded()
            return
        } 
        
        // -
        let loaderViewController = WaitingViewController()
        loaderViewController.casualViewControllerClosure = casualViewControllerClosure
        loaderViewController.application = application
        window.rootViewController = loaderViewController
        window.makeKeyAndVisible()
    }
    
    func configurePurcaseViewIfNeeded() {
        if startDate < Date() { return }
        if !App2Shared.shared.needShowPurchaseBanner { return }
        let purchaseView = PurchaseView()
        purchaseView.backgroundColor = UIColor.lightGray
        let tabBarHeight: CGFloat = 80
        let yPosition = UIScreen.main.bounds.height - 70 - tabBarHeight
        purchaseView.frame = CGRect(x: 0, y: yPosition, width: UIScreen.main.bounds.width, height: 70)
        window.addSubview(purchaseView)
    }
    
}

// MARK: -
// MARK: - Loading view controller

extension App2Delagate {
    
    func subscribeOnNotifications() {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: mainQueue) { [weak self] notification in
            App2DeleNotificationManager.shared.resetAllPushNotifications()
            self?.udkManager.setIsCl()
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
                App2DeleNotificationManager.shared.resetAllPushNotifications()
                udkManager.setIsCl()
                fatalError()
            }
        }
    }
    
}
