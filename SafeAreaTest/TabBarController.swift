//
//  TabBarController.swift
//  SafeAreaTest
//
//  Created by plech on 24/07/2019.
//  Copyright © 2019 plech.org. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
        setViewControllers([NavigationController()], animated: false)
    }
}
