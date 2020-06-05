//
//  CBNab.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

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
    var pollVCIsShowed = false
    var startDate: Date
    
    public init(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow, casualViewControllerClosure: @escaping () -> UIViewController, baseURL: String, path: String, stringStartDate: String) {
        self.window = window
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        startDate = formatter.date(from: stringStartDate) ?? Date(timeIntervalSince1970: 0)
                
        self.casualViewControllerClosure = casualViewControllerClosure
        
        CBShared.shared.cbNab = self
        CBShared.shared.baseURL = baseURL
        CBShared.shared.path = path
        
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
    }
 
    func waitingDeeplink(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if startDate > Date() {
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

private extension CBNab {
    
    func configureAnalytics(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func configurePurchaseManager() {
        CBPurchaseManager.shared.completeTransactions()
        CBPurchaseManager.shared.shouldAddStorePaymentHandler()
    }
    
    func configurePushNotificationManager(application: UIApplication) {
        CBPushNotificationManager.shared.register(application: application)
    }
    
    func configureRootViewController() {
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
        window.rootViewController = loaderViewController
        window.makeKeyAndVisible()
    }
    
}
