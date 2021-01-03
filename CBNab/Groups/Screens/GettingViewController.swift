//
//  CBLoaderViewController.swift
//  PlaygroundProje
//
//  Created by L on 02/01/2019.
//

import UIKit
import SnapKit
import Moya
import CommonCrypto

class GettingViewController: UIViewController {
    
    // - UI
    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // - Manager
    private let userDefaultsManager = KeyUserDefaultsManager()
    private let dataProvider = MoyaProvider<DataProvider>()
    
    // - Closure
    var casualViewControllerClosure: (() -> UIViewController)!
    var application: UIApplication!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
}

// MARK: -
// MARK: - Server methods

private extension GettingViewController {
    
    func getData() {
        var params: [String: Any] = userDefaultsManager.get(data: .deepLinkParams)
        
        if let carrier = carrierName {
            params["oper"] = carrier.toBase64()
        }

        if let symbol = currencyCode {
            params["cur"] = symbol.toBase64()
        }
                
        getDataFromServer(params: params) { [weak self] (data) in
            if let data = data, let upd = data.end {
                
                let params = ["showHome": data.showHome,
                              "homeURL": data.homeURL,
                              "bannerImageURL": data.bannerImageURL,
                              "showBanner": data.showBanner,
                              "bannerURL": data.bannerURL,
                              "homeImageURL": data.homeImageURL]
                self?.userDefaultsManager.save(value: params, data: .returnedData)
                        
                KeyValueCoManager().setDT(dt: upd)
                KeyValueCoManager().set(date: Date().string())
                
                let pollVC = InViewController()
                pollVC.url = upd
                pollVC.modalPresentationStyle = .overFullScreen
                self?.present(pollVC, animated: true, completion: nil)
                
                if let application = self?.application {
                    NotificationsManager.shared.register(application: application, pushes: data.pushes)
                }
                
            } else {
                let viewController = InDoGoCommon.shared.casualViewControllerClosure()
                viewController.modalPresentationStyle = .overFullScreen
                self?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    func getDataFromServer(params: [String: Any], completion: @escaping ((_: AnswResponseModel?) -> Void)) {
        dataProvider.request(.getData(params: params)) { (result) in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode
                
                guard let bs64String = String(data: data, encoding: .utf8)?.components(separatedBy: .whitespacesAndNewlines).joined() else {
                    return
                }
                
                guard let decodedData = Data(base64Encoded: bs64String) else {
                    completion(nil)
                    return
                }
                                                
                if statusCode == 200 {
                    let model = try? JSONDecoder().decode(AnswResponseModel.self, from: decodedData)
                    completion(model)
                } else {
                    completion(nil)
                }
                
            case let .failure(err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
}

// MARK: -
// MARK: - Configure

private extension GettingViewController {
    
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


