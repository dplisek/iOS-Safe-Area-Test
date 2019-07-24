//
//  ViewController.swift
//  SafeAreaTest
//
//  Created by plech on 23/07/2019.
//  Copyright © 2019 plech.org. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var constraint: SafeAreaSafeConstraint!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        print("Constraints updated, add a breapoint here to check them out!")
    }
}
