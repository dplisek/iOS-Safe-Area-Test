//
//  NavigationController.swift
//  SafeAreaTest
//
//  Created by plech on 24/07/2019.
//  Copyright © 2019 plech.org. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        setViewControllers([ViewController()], animated: false)
    }
}
