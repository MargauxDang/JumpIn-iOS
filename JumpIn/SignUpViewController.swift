//
//  SignUpViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 01/11/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var signUp: UIButton!
    @IBOutlet var usernameInput: UITextField!
    @IBOutlet var passwordInput: UITextField!
    @IBOutlet var weightInput: UITextField!
    @IBOutlet var highInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUp.layer.cornerRadius = 5.0
        
        //Hide keyboard
        self.usernameInput.delegate = self
        self.passwordInput.delegate = self
        self.weightInput.delegate = self
        self.highInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func createAccount(_ sender: Any) {
        //If username and password are filled
        let weight = weightInput.text
        let high = highInput.text
        
        if let username = usernameInput.text, let password = passwordInput.text {
            
            //Create user
            Auth.auth().createUser(withEmail: username, password: password, completion: { user, error in
                
                //Errors
                if let firebaseError = error {
                    self.createAlert(title: "Error", message: firebaseError.localizedDescription)
                    return
                }
                else {
                    //Add to the firebase DB
                    let databaseRef = Database.database().reference(fromURL: "https://jumpin-c4b57.firebaseio.com/")
                    let usersRef = databaseRef.child("users").child((user?.uid)!)
                    let userValues  = ["username" : username, "weight" : weight, "high" : high]
                    usersRef.updateChildValues(userValues, withCompletionBlock: { (err, databaseRef) in
                        if err != nil {
                            self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                            return
                        }
                    })
                
                    self.redirectionScreen()

                }
            })
        }
    }

    //Redirection
    func redirectionScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let redirect:MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.present(redirect, animated: true, completion: nil)
    }
    
    //Create a pop up alert
    func createAlert(title: String, message:String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Hide keyboard when user touches outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide keyboard when user touches return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameInput.resignFirstResponder()
        passwordInput.resignFirstResponder()
        weightInput.resignFirstResponder()
        highInput.resignFirstResponder()
        return true
    }
    

}
