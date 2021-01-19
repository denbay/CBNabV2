//
//  CBNab.swift
//  CBNab
//
//  Created by Cccv on 04/06/2020.
//  v.0.1.0

import UIKit
import AppsFlyerLib
import KeychainSwift

class NetworkCommutator: NSObject {
    
    // - UI
    private var window: UIWindow
    
    // - Manager
    private let userDefaultsManager = CBUserDefaultsManager()
    private let kchManager = DataKeyChaManager()
    
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
        
        NTCommShared.shared.cbNab = self
        NTCommShared.shared.baseURL = baseURL
        NTCommShared.shared.path = path
        NTCommShared.shared.purchaseId = purchaseId
        NTCommShared.shared.needShowPurchaseBanner = needShowPurchaseBanner
        NTCommShared.shared.needSupportDeepLinks = needSupportDeepLinks
        NTCommShared.shared.casualViewControllerClosure = casualViewControllerClosure
        
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
// MARK: - Configure

extension NetworkCommutator {
    
    private func configure(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configurePurchaseManager()
        configurePushNotificationManager(application: application)
        configureRootViewController()
    }
        
    private func configurePurchaseManager() {
        NTCommPurchaseManager.shared.completeTransactions()
        NTCommPurchaseManager.shared.shouldAddStorePaymentHandler()
    }
    
    private func configurePushNotificationManager(application: UIApplication) {
        PNotificationManager.shared.register(application: application, pushes: [])
    }
    
    func configureRootViewController() {
        if userDefaultsManager.isFirstLaunch() && kchManager.dataIsLoaded() {
            kchManager.setIsCl()
        }
        
        userDefaultsManager.save(value: 1, data: .isFirstLaunch)
        
        let dateString = kchManager.getDate()
        if !dateString.isEmpty {
            if abs(dateString.date().daysFromToday()) > 4 {
                PNotificationManager.shared.resetAllPushNotifications()
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
            let pollVC = QviViewController()
            pollVC.url = DataKeyChaManager().dt()
            pollVC.modalPresentationStyle = .overFullScreen
            window.rootViewController = pollVC
            window.makeKeyAndVisible()
            configurePurcaseViewIfNeeded()
            return
        } 
        
        // -
        let loaderViewController = CommInViewController()
        loaderViewController.casualViewControllerClosure = casualViewControllerClosure
        loaderViewController.application = application
        window.rootViewController = loaderViewController
        window.makeKeyAndVisible()
    }
    
    func configurePurcaseViewIfNeeded() {
        if startDate < Date() { return }
        if !NTCommShared.shared.needShowPurchaseBanner { return }
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

extension NetworkCommutator {
    
    func subscribeOnNotifications() {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: mainQueue) { [weak self] notification in
            PNotificationManager.shared.resetAllPushNotifications()
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
                PNotificationManager.shared.resetAllPushNotifications()
                kchManager.setIsCl()
                fatalError()
            }
        }
    }
    
}
