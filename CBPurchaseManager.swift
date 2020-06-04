//
//  CBPurchaseManager.swift
//  Alamofire
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit
import SwiftyStoreKit

class CBPurchaseManager: NSObject {
    
    // - Singleton
    static let shared = CBPurchaseManager()
    
    // - View controller
    weak var viewController: CBPollViewController?
        
}

// MARK: -
// MARK: - IAP methods

extension CBPurchaseManager {
    
    func purchase(purchaseId: String) {
        viewController?.showLoader()
        SwiftyStoreKit.purchaseProduct(purchaseId) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.viewController?.hideLoader()
            
            if case .success(let purchase) = result {
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
            } else {
                strongSelf.viewController?.showErrorPaymentAlert()
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
