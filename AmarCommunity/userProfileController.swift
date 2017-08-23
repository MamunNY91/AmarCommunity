//
//  UserProfileController.swift
//  AmarCommunity
//
//  Created by Abdullah A Mamun on 8/23/17.
//  Copyright © 2017 Abdullah A Mamun. All rights reserved.
//

import UIKit
import Firebase
class UserProfileController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        fetchUser()
    }
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            print(snapshot.value ?? "")
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let username = dictionary ["username"] as? String
            self.navigationItem.title = username
            
        }) { (err) in
            print("Failed to fetch user's info")
        }
    }
}
