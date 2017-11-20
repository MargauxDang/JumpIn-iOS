//
//  StatViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class StatViewController: UIViewController {
    
    
    @IBOutlet var jumpNb: UIButton!
    @IBOutlet var calories: UIButton!
    @IBOutlet var duration: UIButton!
    @IBOutlet var altitude: UIButton!
    var newJump: String!
    var newCalories: String!
    var newDuration: String!
    var newAltitude: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Print the data of the last session
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session1").observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.newJump = dictionary["jumps"] as? String
                self.newCalories = dictionary["calories"] as? String
                self.newDuration = dictionary["duration"] as? String
                self.newAltitude = dictionary["altitude"] as? String
                
                self.jumpNb.setTitle(self.newJump, for: .normal)
                self.calories.setTitle(self.newCalories, for: .normal)
                self.duration.setTitle(self.newDuration, for: .normal)
                self.altitude.setTitle(self.newAltitude, for: .normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Share the result on social media
    @IBAction func shareResult(_ sender: Any) {
        
        let activityController = UIActivityViewController(activityItems: ["Hi! I just finished my session on JumpIn app. I did \(self.newJump!) jumps, I burnt \(self.newCalories!) calories and my average altitude is \(self.newAltitude!) during \(self.newDuration!) minutes. Try this app! 😃"], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}

