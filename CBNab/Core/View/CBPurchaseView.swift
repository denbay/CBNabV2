//
//  CBPurchaseView.swift
//  Alamofire
//
//  Created by Uk on 17.07.2020.
//

import UIKit

class CBPurchaseView: UIView {
    
    // - UI
    private let restoreButton = UIButton()
    private let closeButton = UIButton()
    private let adsLabel = UILabel()
    
    // - Manager
    private var userDefaultsManager = CBUserDefaultsManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1335547405"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeButtonAction(_ sender: UIButton) {
        CBPurchaseManager.shared.purchase(purchaseId: StateHL.shared.purchaseId, completion: { [weak self] error in
            self?.hideIfNeeded()
        })
    }
    
    @objc func restoreButtonAction(_ sender: UIButton) {
        CBPurchaseManager.shared.restorePurchases()
    }
    
}

// MARK: -
// MARK: - Configure

private extension CBPurchaseView {
    
    func configure() {
        hideIfNeeded()
        configureAdsLabel()
        configureCloseButton()
        configureRestorePurchasesButton()
    }
    
    func hideIfNeeded() {
        if userDefaultsManager.get(data: .purchased) {
            isHidden = true
        }
    }
    
    func configureAdsLabel() {
        adsLabel.text = "Coin\nKeeper"
        adsLabel.textAlignment = .center
        adsLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        adsLabel.numberOfLines = 2
        adsLabel.sizeToFit()
        adsLabel.frame.origin = CGPoint(
            x: (UIScreen.main.bounds.width - adsLabel.frame.size.width) / 2,
            y: (70 - adsLabel.frame.size.height) / 2)
        addSubview(adsLabel)
    }
    
    func configureCloseButton() {
        closeButton.backgroundColor = UIColor.white
        closeButton.layer.cornerRadius = 13
        closeButton.frame = CGRect(x: UIScreen.main.bounds.width - 5 - 140, y: 5, width: 140, height: 26)
        closeButton.setTitle("Remove ads for $0.99", for: .normal)
        closeButton.setTitleColor(UIColor.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        addSubview(closeButton)
    }
    
    func configureRestorePurchasesButton() {
        restoreButton.backgroundColor = UIColor.white
        restoreButton.layer.cornerRadius = 13
        restoreButton.frame = CGRect(x: 5, y: 5, width: 120, height: 26)
        restoreButton.setImage(UIImage(named: "closeSmallIcon.png"), for: .normal)
        restoreButton.setTitle("Restore purchases", for: .normal)
        restoreButton.setTitleColor(UIColor.black, for: .normal)
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        restoreButton.addTarget(self, action: #selector(restoreButtonAction(_:)), for: .touchUpInside)
        addSubview(restoreButton)
    }
    
}
