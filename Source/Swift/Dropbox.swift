//
//  Dropbox.swift
//  PayNoteBeta
//
//  Created by 松山正和 on 2017/09/18.
//

import UIKit
import SwiftyDropbox


class Dropbox: NSObject {
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Public value
    
    
    
    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Private value
    private static let singleInstance = Dropbox() // シングルトン・インタンス --> 初期処理 init()
    
//    private var tokenValue:String = ""
//    private var token:String! {
//        get {
//            if tokenValue == "" {
//                // 再取得
//                tokenValue = tokenReset()
//            }
//            else {
//                // 有効期限チェック
//
//                tokenValue = tokenReset()
//            }
//            return tokenValue
//        }
//    }
    
    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Public func
    class func singleton() -> Dropbox! {
        return singleInstance;
    }
    
    // Begin the authorization flow
    func authBegin() {
        if (DropboxClientsManager.authorizedClient == nil) {
            // 最前面のViewControllerを取得する
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while let vc = topViewController?.presentedViewController {
                if !(vc is UINavigationController) {
                    topViewController = vc
                }
            }
            guard topViewController != nil else {
                return;
            }
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: topViewController!,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.openURL(url)
                                                            //self.authResult( openUrl: url )
            })
        }
    }
    
    // func application(_ app: , open url: , options: ) で戻ったとき呼び出す
    func authResult( openUrl:URL! ) {
        if let authResult = DropboxClientsManager.handleRedirectURL(openUrl) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                AZAlert.target(nil, title: "Dropbox",
                               message: NSLocalizedString("Successfully connected to Dropbox!", comment:""),
                               completion: nil)
            case .cancel:
                print("Authorization flow was manually canceled by user!")
                AZAlert.target(nil, title: "Dropbox",
                               message: NSLocalizedString("Canceled connection to Dropbox", comment:""),
                               completion: nil)
            case .error(_, let description):
                print("Error: \(description)")
                AZAlert.target(nil, title: "Dropbox Error",
                               message: description,
                               completion: nil)
            }
        }
    }
    
    func authUnlink() {
        DropboxClientsManager.unlinkClients()
    }
    
    func upload( path:String!, fileData:Data!, completion: ((Bool) -> Void)! ) -> Void {
        //let fileData = "testing data example".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        // Reference after programmatic auth flow
        if let client = DropboxClientsManager.authorizedClient {
            _ = client.files.upload(path:path, mode:.overwrite, input:fileData)
                .response { response, error in
                    if let response = response {
                        print(response)
                        completion(true)
                        
                    } else if let error = error {
                        print(error)
                        completion(false)
                    }
                    completion(false)
                }
                .progress { progressData in
                    print(progressData)
            }
        }
        else {
            completion(false)
            self.authBegin()
        }
    }

    func download( path:String!, completion: ((Bool,Data?) -> Void)! ) -> Void {
        // Reference after programmatic auth flow
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: path)
                .response { response, error in
                    if let response = response {
                        let responseMetadata = response.0
                        print(responseMetadata)
                        let fileContents = response.1
                        print(fileContents)
                        completion(true, fileContents)
                    }
                    else if let error = error {
                        print(error)
                        completion(false, nil)
                    }
                    else {
                        completion(false, nil)
                    }
                }
                .progress { progressData in
                    print(progressData)
            }
        }
        else {
            completion(false, nil)
            self.authBegin()
        }
    }

    
    ////////////////////////////////////////////////////////////////
    // MARK: - Private func
    
    // シングルトン・インスタンスの初期処理
    private override init() {  //シングルトン保証// privateにすることにより他から初期化させない
        // Initialize a DropboxClient instance
        DropboxClientsManager.setupWithAppKey("42p233hc0205y0k")
    }
    
    
    
}

extension UIViewController {
    /// 最前面のViewControllerを取得する
    class func getTopViewController() -> UIViewController {
        var viewController = UIApplication.shared.keyWindow?.rootViewController
        while let vc = viewController?.presentedViewController {
            if !(vc is UINavigationController) {
                viewController = vc
            }
        }
        return viewController!
    }
}



