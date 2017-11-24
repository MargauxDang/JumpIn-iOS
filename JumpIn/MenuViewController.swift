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
    @IBOutlet var remainingJump: UILabel!
    
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
        
        //Retrieve the number of jumps remaining
        Database.database().reference().child("sessions").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let totalJump = dictionary["totalJump"] as? Int
                if totalJump != nil {
                let totalString = String(totalJump!)
                self.remainingJump.text = "Jumps remaining: \(totalString)"
                }
            }
        }
    }
    
    @IBAction func play(_ sender: Any) {
        //Check if the counter is equal to 0
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let totalJump = dictionary["totalJump"] as? Int
                if totalJump != nil {
                    self.redirection(counter: totalJump!)
                }
            }
        }
    }
    
    //Redirection
    func redirection(counter: Int) {        
        if counter == 0 {
            self.createAlert(title: "Error", message: "Sorry, you have to jump again in order to play")
        } else {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let redirect:GameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            self.present(redirect, animated: true, completion: nil)
        }
    }
    
    //Alert
    func createAlert(title: String, message:String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.destructive, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title:"Jump", style:UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"JumpViewController") as! JumpViewController
            self.present(viewController, animated: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
