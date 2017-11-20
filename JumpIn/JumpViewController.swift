//
//  JumpViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class JumpViewController: UIViewController {
    
    @IBOutlet var jumpText: UITextField!
    @IBOutlet var pausestart: UIButton!
    @IBOutlet var stop: UIButton!
    var pause = false
    var sessionNb: String!
    var ref:DatabaseReference!
    var weight:String!
    
    var timer = Timer()
    @IBOutlet var timerLabel: UILabel!
    var seconde = 0
    var minute = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pausestart.layer.cornerRadius = 10.0
        stop.layer.cornerRadius = 10.0
        timerLabel.text = String(format: "%02d:%02d", minute, seconde)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //User click on pause
    @IBAction func pause(_ sender: Any) {
        if pause == true {
            pausestart.setTitle(">",for: .normal)
            pause = false
            timer.invalidate()
            
        } else if pause == false {
            pausestart.setTitle("| |", for: .normal)
            pause = true
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JumpViewController.action), userInfo: nil, repeats: true)
        }
    }
    
    @objc func action() {
        if seconde == 59 {
            seconde = 0
            minute = minute+1
        } else {
            seconde = seconde+1
        }
        
        timerLabel.text = String(format: "%02d:%02d", minute, seconde)

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
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value)
        { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                self.weight = dic["weight"] as? String
                self.calculeCalories(weight: self.weight)
            }
        }
    }
    
    func calculeCalories(weight: String) {
        let jumpValue = jumpText.text
        let durationValue = "\(minute).\(seconde)"
        
        //String to double
        let durationDouble = Double(durationValue)
        let weightDouble = Double(weight)
        let calorieDouble = (7.5*3.5*weightDouble!)/200.0
        let calorie = round(calorieDouble*durationDouble!)
        let calorieValue = String(calorie)
        let altitudeValue = "1"
        
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
                    let sessionValues  = ["jumps":jumpValue, "calories":calorieValue, "duration":durationValue, "altitude":altitudeValue] as [String : Any]
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
                    //Update the counter, incrementation
                    let newCounter = Int(self.sessionNb)! + 1
                    let counterString = String(newCounter)
                    self.ref = Database.database().reference()
                    self.ref.child("sessions").child(userID).updateChildValues(["counter": counterString])
                    self.redirectionScreen()
                    
                    //Add the new session
                   // self.addNewCounter()
                }
            }
        }
    }

    
    func addNewCounter() {
        
        let jumpValue = jumpText.text
        let durationValue = "\(minute).\(seconde)"
        let durationDouble = Double(durationValue)
        let weightDouble = Double(weight)
        let calorieDouble = (7.5*3.5*weightDouble!)/200.0
        let calorie = round(calorieDouble*durationDouble!)
        let calorieValue = String(calorie)
        let altitudeValue = "1"
        
        //Add the new session to session n°1
        let databaseRef = Database.database().reference(fromURL: "https://jumpin-c4b57.firebaseio.com/")
        let userID = (Auth.auth().currentUser?.uid)!
        let usersRef = databaseRef.child("sessions").child(userID).child("session1")
        let sessionValues  = ["jumps":jumpValue, "calories":calorieValue, "duration":durationValue, "altitude":altitudeValue] as [String : Any]
        usersRef.updateChildValues(sessionValues, withCompletionBlock: { (err, databaseRef) in
            if err != nil {
                self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                return
            }
        })
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
