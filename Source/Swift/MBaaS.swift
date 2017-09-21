//
//  MBaaS.swift
//  PayNote
//
//  Created by 松山正和 on 2017/09/18.
//

import Foundation
import Firebase


class MBaaS: NSObject { // ObjCから使用するためNSObjectのサブクラスにする
    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Public value
    
    
    
    

    ////////////////////////////////////////////////////////////////
    // MARK: - Private value
    private static let singleInstance = MBaaS() // シングルトン・インタンス --> 初期処理 init()

    private var tokenValue:String = ""
    private var token:String! {
        get {
            if tokenValue == "" {
                // 再取得
                tokenValue = tokenReset()
            }
            else {
                // 有効期限チェック
                
                tokenValue = tokenReset()
            }
            return tokenValue
        }
    }
    
    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Public func
    class func singleton() -> MBaaS! {
        return singleInstance;
    }

    /**
     *
     */
    func loginNew( email:String!, password:String!, completion: ((Bool) -> Void)! ) -> Void {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
        })
    }
    
    /**
     *
     */
    func login( email:String!, password:String!, completion: ((Bool) -> Void)! ) -> Void {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if user != nil {
//                let uid = user.uid
//                let email = user.email
//                let photoURL = user.photoURL
            }
            
            
        })
    }

    
    /**
     *
     */
    func upFile( localFile:URL!, completion: ((Bool) -> Void)! ) -> Void {
        
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let bataRef = storageRef.child("bata")
        let sampleRef = bataRef.child("sample.csv")
        
        // Create file metadata including the content type
        let metadata = FIRStorageMetadata()
        metadata.contentType = "file/csv"
        
        // Upload the file to the path
        _ = sampleRef.putFile(localFile, metadata: metadata,
                              completion: { (metadata, error) in
                                if error != nil {
                                    // Uh-oh, an error occurred!
                                } else {
                                    // Metadata contains file metadata such as size, content-type, and download URL.
                                    let downloadURL = metadata!.downloadURL()
                                }
        })
    }

    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Private func
    
    // シングルトン・インスタンスの初期処理
    private override init() {  //シングルトン保証// privateにすることにより他から初期化させない
        // Use Firebase library to configure APIs
        FIRApp.configure()
    }
    
    /**
     *
     */
    private func tokenReset() -> String! {

        return ""
    }
    

}
