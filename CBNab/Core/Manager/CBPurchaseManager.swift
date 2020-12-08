//
//  CBPurchaseManager.swift
//  Alamofire
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit
import SwiftyStoreKit
import SVProgressHUD

class CBPurchaseManager: NSObject {
    
    // - Singleton
    static let shared = CBPurchaseManager()
    
    // - Manager
    private var userDefaults = CBUserDefaultsManager()
    
    // - View controller
    weak var viewController: CBPollViewController?
        
}

// MARK: -
// MARK: - IAP methods

extension CBPurchaseManager {
    
    func purchase(purchaseId: String, completion: (() -> Void)? = nil) {
        SVProgressHUD.show()
        
        SwiftyStoreKit.purchaseProduct(purchaseId) { [weak self] result in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else { return }
            
            if case .success(let purchase) = result {
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                self?.userDefaults.save(value: true, data: .purchased)
                if let completion = completion {
                    completion()
                }
            } else {
                strongSelf.viewController?.showErrorPaymentAlert()
            }
        }
    }
    
    func restorePurchases() {
        SVProgressHUD.show()
        
        SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
            SVProgressHUD.dismiss()
            
            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                 self?.userDefaults.save(value: true, data: .purchased)
            }
            
            if let topVC = UIApplication.getTopViewController() {
                topVC.showAlert(message: "Purchase restored!")
            }
        }
    }
    
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    
    func shouldAddStorePaymentHandler() {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { [weak self] payment, product in
            self?.purchase(purchaseId: product.productIdentifier)
            return false
        }
    }
        
}
