//
//  CBNab.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//  v.0.1.0

import UIKit
import Branch
import FBSDKCoreKit

public class CBNab {
    
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
    
    public init(
            _ application: UIApplication,
            launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
            window: UIWindow,
            casualViewControllerClosure: @escaping () -> UIViewController,
            baseURL: String, path: String,
            stringStartDate: String,
            type: CBType,
            purchaseId: String,
            needShowPurchaseView: Bool = true,
            needShowCrashAfterScreen: Bool = false,
            needSupportDeepLinks: Bool = false) {
        self.window = window
        self.application = application
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        startDate = formatter.date(from: stringStartDate) ?? Date(timeIntervalSince1970: 0)
                
        self.casualViewControllerClosure = casualViewControllerClosure
        
        CBShared.shared.cbNab = self
        CBShared.shared.baseURL = baseURL
        CBShared.shared.path = path
        CBShared.shared.type = type
        CBShared.shared.purchaseId = purchaseId
        CBShared.shared.needShowPurchaseView = needShowPurchaseView
        CBShared.shared.needShowCrashAfterScreen = needShowCrashAfterScreen
        CBShared.shared.needSupportDeepLinks = needSupportDeepLinks
        
        configure(application, launchOptions: launchOptions)
    }

}

// MARK: -
// MARK: - Deeplink handling

private extension CBNab {
    
    func configure(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configureAnalytics(application, launchOptions: launchOptions)
        configurePurchaseManager()
        configurePushNotificationManager(application: application)
        configureRootViewController()
        waitingDeeplink(launchOptions: launchOptions)
        subscribeOnDidTakeScreenshotIfNeeded()
    }
 
    func waitingDeeplink(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if startDate > Date() {
            return
        }
    
        if !CBShared.shared.needSupportDeepLinks {
            return
        }
                
        let branch = Branch.getInstance()
        branch.delayInitToCheckForSearchAds()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { [weak self] (params, error) in
            if error == nil {
                guard let params = params else { return }
                if let stringParams = self?.deepLinkManager.handleDeepLink(params: params) {
                    if let _ = stringParams["landing"] {
                        self?.userDefaultsManager.save(value: false, data: .dataIsGetted)
                        self?.pollVCIsShowed = false
                        self?.configureRootViewController()
                    }
                }
            }
        })

        AppLinkUtility.fetchDeferredAppLink { [weak self] (url, error) in
            if let url = url {
                if let stringParams = self?.deepLinkManager.handleFBDeeplink(url: url) {
                    if let _ = stringParams["landing"] {
                        self?.userDefaultsManager.save(value: false, data: .dataIsGetted)
                        self?.pollVCIsShowed = false
                        self?.configureRootViewController()
                    }
                }
            }
        }
    }
    
}

// MARK: -
// MARK: - Configure

extension CBNab {
    
    private func configureAnalytics(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
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
            configurePurcaseViewIfNeeded()
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
            configurePurcaseViewIfNeeded()
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
    
    func configurePurcaseViewIfNeeded() {
        if startDate < Date() { return }
        if !CBShared.shared.needShowPurchaseView { return }
        let purchaseView = CBPurchaseView()
        purchaseView.backgroundColor = UIColor.lightGray
        let tabBarHeight: CGFloat = 80
        let yPosition = UIScreen.main.bounds.height - 70 - tabBarHeight
        purchaseView.frame = CGRect(x: 0, y: yPosition, width: UIScreen.main.bounds.width, height: 70)
        window.addSubview(purchaseView)
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
