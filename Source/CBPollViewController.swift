//
//  CBPollViewController.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit
import WebKit
import SnapKit

class CBPollViewController: UIViewController {
    
    // - UI
    private let pollView = WKWebView()
    private let activityIndicator = UIActivityIndicatorView()
    
    // - Manager
    private let purchaseManager = CBPurchaseManager()
    
    // - Data
    private var pageIsLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func redirectToSuccessURL() {
        let url = getLastToken() + "?paid=true"
        let request = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        pollView.load(request)
    }
    
    func showErrorPaymentAlert() {
        showAlert("Error", message: "Please, try again later.")
    }
    
}

// MARK: -
// MARK: - Loader logic

extension CBPollViewController {
    
    func showLoader() {
        activityIndicator.alpha = 1
        activityIndicator.center = view.center
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
}

// MARK: -
// MARK: - Web view delegate

extension CBPollViewController: WKNavigationDelegate {
        
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            parse(url: url)
        }
        
        decisionHandler(.allow)
    }
    
    func parse(url: URL) {
        var params = [String: String]()
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        if let queryItems = components.queryItems {
            for item in queryItems {
                params[item.name] = item.value ?? ""
            }
        }
        
        if let purchaseId = params["purchaseId"] {
            purchaseManager.purchase(purchaseId: purchaseId)
        }
        
        if let _ = params["close"] {
            CBUserDefaultsManager().save(value: true, data: .needClose)
            CBShared.shared.cbNab.configureRootViewController()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !pageIsLoaded {
            pageIsLoaded = true
            hideLoader()
        }
    }
    
}

// MARK: -
// MARK: - Web view UI delegate

extension CBPollViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
}

// MARK: -
// MARK: - Configure

private extension CBPollViewController {
    
    func configure() {
        CBShared.shared.cbNab.pollVCIsShowed = true
        configureUI()
        configurePurchaseManager()
        configurePollView()
    }
    
    func configurePurchaseManager() {
        purchaseManager.viewController = self
    }
    
    func configurePollView() {
        guard let url = URL(string: getLastToken()) else { return }
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        pollView.scrollView.contentInsetAdjustmentBehavior = .never
        pollView.navigationDelegate = self
        pollView.uiDelegate = self
        pollView.load(request)
    }
    
    func configureUI() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(pollView)
        pollView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            make.left.equalTo(view).offset(0)
            make.right.equalTo(view).offset(0)
            make.bottom.equalTo(view).offset(0)
        }
        
        activityIndicator.isHidden = true
        activityIndicator.style = .gray
        activityIndicator.alpha = 0
        view.addSubview(activityIndicator)
        
        showLoader()
    }
    
}

// MARK: -
// MARK: - Store

extension CBPollViewController {
    
    func setLast(token: String) {
        let crypt = CBCrypt()
        let token = crypt.encrypt(string: token, key: 4)
        UserDefaults.standard.set(token.toBase64(), forKey: "accessToken")
    }
    
    func getLastToken() -> String {
        let crypt = CBCrypt()
        let tokenFromBase64 = UserDefaults.standard.string(forKey: "accessToken")?.fromBase64() ?? ""
        let token = crypt.decrypt(string: tokenFromBase64, key: 4)
        return token
    }
    
}
