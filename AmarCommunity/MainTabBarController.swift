//
//  MainTabBarController.swift
//  AmarCommunity
//
//  Created by Abdullah A Mamun on 8/23/17.
//  Copyright © 2017 Abdullah A Mamun. All rights reserved.
//

import UIKit
class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        // now we want a navigation controller at the top
        let navController = UINavigationController(rootViewController: userProfileController)
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        tabBar.tintColor = .black
        
        viewControllers = [navController, UIViewController()]
        
    
    }
}
