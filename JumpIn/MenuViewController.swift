//
//  MenuViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import Firebase

class MenuViewController: UIViewController {

    @IBOutlet var train: UIButton!
    @IBOutlet var jumps: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        train.layer.cornerRadius = 5.0
    
        //Retrieve values
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session1").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.jumps.setTitle(userDict["jumps"] as? String, for: .normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
