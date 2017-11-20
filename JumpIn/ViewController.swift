//
//  ViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var start: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start.layer.cornerRadius = 5.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
