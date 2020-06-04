//
//  CBLoaderViewController.swift
//  CBNab
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit
import SnapKit
import Moya

class CBLoaderViewController: UIViewController {
    
    // - UI
    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // - Manager
    private let userDefaultsManager = CBUserDefaultsManager()
    private let dataProvider = MoyaProvider<CBDataProvider>()
    
    // - Closure
    var casualViewControllerClosure: (() -> UIViewController)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
}

// MARK: -
// MARK: - Server methods

private extension CBLoaderViewController {
    
    func getData() {
        let params: [String: Any] = userDefaultsManager.get(data: .deepLinkParams)
        getDataFromServer(params: params) { [weak self] (data) in
            if let upd = data?.landing {
                let pollVC = CBPollViewController()
                pollVC.setLast(url: upd)
                pollVC.modalPresentationStyle = .overFullScreen
                self?.present(pollVC, animated: true, completion: nil)
                self?.userDefaultsManager.save(value: true, data: .dataIsGetted)
            } else {
                let viewController = self?.casualViewControllerClosure() ?? UIViewController()
                viewController.modalPresentationStyle = .overFullScreen
                self?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    func getDataFromServer(params: [String: Any], completion: @escaping ((_: CBResponseModel?) -> Void)) {
        dataProvider.request(.getData(params: params)) { (result) in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode
                
                if statusCode == 200 {
                    let model = try? JSONDecoder().decode(CBResponseModel.self, from: data)
                    completion(model)
                } else {
                    completion(nil)
                }
                
            case .failure:
                completion(nil)
            }
        }
    }
    
}

// MARK: -
// MARK: - Configure

private extension CBLoaderViewController {
    
    func configure() {
        configureLoaderImageView()
        getData()
    }
    
    func configureLoaderImageView() {
        view.backgroundColor = UIColor.white
        
        activityIndicatorView.startAnimating()
        view.addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
}
