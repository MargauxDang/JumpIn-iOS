//
//  InfoViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class InfoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var logOut: UIButton!
    @IBOutlet var modify: UIButton!
    @IBOutlet var connectButton: UIButton!
    
    @IBOutlet var weightInput: UITextField!
    @IBOutlet var highInput: UITextField!
    var dict : [String : AnyObject]!
    var user = Auth.auth().currentUser
    var currentUser = ""
    var postData = [String]()
    var ref:DatabaseReference!
    var refHandle: UInt!
    
    override func viewDidLoad() {
        modify.layer.cornerRadius = 5.0
        logOut.layer.cornerRadius = 5.0
        connectButton.layer.cornerRadius = 5.0
        super.viewDidLoad()
        
        //Hide keyboard
        self.weightInput.delegate = self
        self.highInput.delegate = self
        
        //Facebook connexion
        let FBbutton = LoginButton(readPermissions: [ .publicProfile ])
        let newCenter = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: 500)
        FBbutton.center = newCenter
        //view.addSubview(FBbutton)
        if (FBSDKAccessToken.current()) != nil{
            getFBUserData()
        }
        
        //Print the weight and the high by accessing to firebase DB
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.highInput.text = dictionary["high"] as? String
                self.weightInput.text = dictionary["weight"] as? String
            }
        }
    }
    
    //Update weight and high data
    @IBAction func modifyTouched(_ sender: Any) {
        let userID = (Auth.auth().currentUser?.uid)!
        ref = Database.database().reference()
        ref.child("users").child(userID).updateChildValues(["weight": weightInput.text!, "high": highInput.text!])
        alertModify(title: "Information", message: "You have modify your data")
    }
    
    //Log out
    @IBAction func logOutTouch(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            redirectionScreen()
        } catch {
            print("Problem log")
        }
    }
    
    //Redirections
    func redirectionMenu() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let redirect:MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.present(redirect, animated: true, completion: nil)
    }
    
    func redirectionScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let redirect:ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(redirect, animated: true, completion: nil)
    }
    
    @IBAction func redirectMerge(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let redirect:UINavigationController = storyboard.instantiateViewController(withIdentifier: "BLEMain") as! UINavigationController
        self.present(redirect, animated: true, completion: nil)
    }
    
    //Create a pop up alert
    func alertModify(title: String, message:String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Dismiss", style:UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.redirectionMenu()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //function is fetching the user data
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    print(self.dict)
                }
            })
        }
    }
    
    //Hide keyboard when user touches outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide keyboard when user touches return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weightInput.resignFirstResponder()
        highInput.resignFirstResponder()
        return true
    }

}


