//
//  CBPurchaseView.swift
//  Alamofire
//
//  Created by Dzianis Baidan on 17.07.2020.
//

import UIKit

class CBPurchaseView: UIView {
    
    // - UI
    private let closeButton = UIButton()
    private let adsLabel = UILabel()
    
    // - Manager
    private var userDefaultsManager = CBUserDefaultsManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeButtonAction(_ sender: UIButton) {
        CBPurchaseManager.shared.purchase(purchaseId: CBShared.shared.purchaseId, completion: { [weak self] in
            self?.hideIfNeeded()
        })
    }

}

// MARK: -
// MARK: - Configure

private extension CBPurchaseView {
    
    func configure() {
        hideIfNeeded()
        configureAdsLabel()
        configureCloseButton()
    }
    
    func hideIfNeeded() {
        if userDefaultsManager.get(data: .purchased) {
            isHidden = true
        }
    }
    
    func configureAdsLabel() {
        adsLabel.text = "Adversting"
        adsLabel.font = UIFont.systemFont(ofSize: 21, weight: .regular)
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
        closeButton.setImage(UIImage(named: "closeSmallIcon.png"), for: .normal)
        closeButton.setTitle("Remove ads for $0.99", for: .normal)
        closeButton.setTitleColor(UIColor.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        addSubview(closeButton)
    }
    
}
