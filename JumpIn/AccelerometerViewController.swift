//
//  AccelerometerViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 20/11/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AccelerometerViewController: UIViewController {
    
    @IBOutlet var jumpText: UITextField!
    @IBOutlet var pausestart: UIButton!
    @IBOutlet var stop: UIButton!
    var pause = false
    var sessionNb: String!
    var ref:DatabaseReference!
    @IBOutlet var countingTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pausestart.layer.cornerRadius = 10.0
        stop.layer.cornerRadius = 10.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //User click on pause
    @IBAction func pause(_ sender: Any) {
        if pause == true {
            pausestart.setTitle(">",for: .normal)
            pause = false
        } else if pause == false {
            pausestart.setTitle("| |", for: .normal)
            pause = true
        }
    }
    
    //User click on stop
    @IBAction func stopTouched(_ sender: Any) {
        //If the user never use the jump, create the counter (if there is no session)
        let databaseRef = Database.database().reference(fromURL: "https://jumpin-c4b57.firebaseio.com/")
        let userID = (Auth.auth().currentUser?.uid)!
        let usersRef = databaseRef.child("sessions").child(userID)
        
        //Check if session 1 exist, else create ot
        databaseRef.child("sessions").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("session1"){
                self.addSession()
            }else{
                let counter  = ["counter": "0"]
                usersRef.updateChildValues(counter, withCompletionBlock: { (err, databaseRef) in
                    self.addSession()
                    if err != nil {
                        self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                        return
                    }
                })
                return
            }
            return
        })
    }
    
    private func addSession() {
        
        //let jumpValue = jumpText.text
        let jumpValue = "150"
        let calorieValue = jumpValue
        let durationValue = "310" //Timer
        let altitudeValue = jumpValue
        
        //Retrieve the counter number
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.sessionNb = dictionary["counter"] as? String
                
                //If it is the first time the user is connected
                if (self.sessionNb=="0") {
                    let databaseRef = Database.database().reference(fromURL: "https://jumpin-c4b57.firebaseio.com/")
                    let userID = (Auth.auth().currentUser?.uid)!
                    let usersRef = databaseRef.child("sessions").child(userID).child("session1")
                    let sessionValues  = ["jumps":jumpValue, "calories":calorieValue, "duration":durationValue, "altitude":altitudeValue]
                    usersRef.updateChildValues(sessionValues, withCompletionBlock: { (err, databaseRef) in
                        if err != nil {
                            self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                            return
                        }
                        
                        //Update the value of the counter
                        let userID = (Auth.auth().currentUser?.uid)!
                        self.ref = Database.database().reference()
                        let newCounter = Int(self.sessionNb)! + 1
                        let counterString = String(newCounter)
                        self.ref.child("sessions").child(userID).updateChildValues(["counter": counterString])
                        self.redirectionScreen()
                    })
                    
                    for i in 2...10 {
                        let newRef = databaseRef.child("sessions").child(userID).child("session\(i)")
                        let newsSessions  = ["jumps":"0", "calories":"0", "duration":"0", "altitude":"0"]
                        newRef.updateChildValues(newsSessions, withCompletionBlock: { (err, databaseRef) in
                            if err != nil {
                                self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                                return
                            }
                        })
                    }
                }
                
                //If there are at least 1 session
                let counter = Int(self.sessionNb)!
                if (counter>0){
                    
                    //For each records, we decale the session n°
                    for i in (1...counter).reversed() {
                        print(i)
                        Database.database().reference().child("sessions").child(userID).child("session\(i)").observeSingleEvent(of: .value)
                        { (snapshot) in
                            if let dic = snapshot.value as? [String: AnyObject] {
                                let newAltitude = dic["altitude"] as? String
                                let newDuration = dic["duration"] as? String
                                let newCalories = dic["calories"] as? String
                                let newJumps = dic["jumps"] as? String
                                let userID = (Auth.auth().currentUser?.uid)!
                                
                                self.ref = Database.database().reference()
                                self.ref.child("sessions").child(userID).child("session\(i+1)").updateChildValues(["altitude": newAltitude,"duration": newDuration, "calories": newCalories, "jumps": newJumps])
                            }
                        }
                    }
                    
                    //Add the new session to session n°1
                    let databaseRef = Database.database().reference(fromURL: "https://jumpin-c4b57.firebaseio.com/")
                    let userID = (Auth.auth().currentUser?.uid)!
                    let usersRef = databaseRef.child("sessions").child(userID).child("session1")
                    let sessionValues  = ["jumps":jumpValue, "calories":calorieValue, "duration":durationValue, "altitude":altitudeValue]
                    usersRef.updateChildValues(sessionValues, withCompletionBlock: { (err, databaseRef) in
                        if err != nil {
                            self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                            return
                        }
                    })
                    
                    //Update the counter, incrementation
                    let newCounter = Int(self.sessionNb)! + 1
                    let counterString = String(newCounter)
                    self.ref = Database.database().reference()
                    self.ref.child("sessions").child(userID).updateChildValues(["counter": counterString])
                    self.redirectionScreen()
                }
            }
        }
    }
    
    
    //Redirection
    func redirectionScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let redirect:StatViewController = storyboard.instantiateViewController(withIdentifier: "StatViewController") as! StatViewController
        self.present(redirect, animated: true, completion: nil)
    }
    
    //Error alert
    func createAlert(title: String, message:String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

