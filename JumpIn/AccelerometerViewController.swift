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
import CoreMotion

class AccelerometerViewController: UIViewController {
    
    @IBOutlet var jumpText: UITextField!
    @IBOutlet var pausestart: UIButton!
    @IBOutlet var stop: UIButton!
    var pause = false
    var sessionNb: String!
    var ref:DatabaseReference!
    var weight:String!
    
    var timer = Timer()
    @IBOutlet var countingTime: UILabel!
    var seconde = 0
    var minute = 0
    
    let imageName = "TapToStart.png"
    var image: UIImage!
    var imageView: UIImageView!
    
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pausestart.layer.cornerRadius = 10.0
        stop.layer.cornerRadius = 10.0
        countingTime.text = String(format: "%02d:%02d", minute, seconde)
        
        image = UIImage(named: imageName)
        imageView = UIImageView(image: image!)
        
        imageView.frame = CGRect(x: view.frame.size.width/8, y: view.frame.size.height-250, width: 150, height: 100)
        view.addSubview(imageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goHome(_ sender: Any) {
        motionManager.stopAccelerometerUpdates()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let redirect:MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.present(redirect, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {}
    
    //User click on pause
    @IBAction func pause(_ sender: Any) {
        if pause == true {
            pausestart.setTitle(">",for: .normal)
            pause = false
            timer.invalidate()
            motionManager.stopAccelerometerUpdates()
            
        } else if pause == false {
            
            //If the user didn't put weight/high, have to alert him
            let userID = (Auth.auth().currentUser?.uid)!
            Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let high = dictionary["high"] as? String
                    let weight = dictionary["weight"] as? String
                    self.startJumping(high: high!, weight: weight!)

                }
            }
        }
    }
    
    func startJumping(high:String, weight:String) {
        
        if (high == "" || weight == "") {
            self.alertMissingInfo(title: "Warning", message: "You have to enter weight and high before starting")
            
        } else {
            pausestart.setTitle("| |", for: .normal)
            pause = true
            imageView.removeFromSuperview()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JumpViewController.action), userInfo: nil, repeats: true)
            
            //Accelerometer
            motionManager.accelerometerUpdateInterval = 1
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
                if let myData = data {
                    print(myData)
                }
            }
        }
    }
    
    @objc func action() {
        if seconde == 59 {
            seconde = 0
            minute = minute+1
        } else {
            seconde = seconde+1
        }
        
        countingTime.text = String(format: "%02d:%02d", minute, seconde)
    }
    
    //User click on stop
    @IBAction func stopTouched(_ sender: Any) {
        motionManager.stopAccelerometerUpdates()
        
        
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
                    
                    //Create a tmp session
                    let refTpmSession = databaseRef.child("sessions").child(userID).child("tmp")
                    let TpmSessions  = ["jumps":"0", "calories":"0", "duration":"0", "altitude":"0"]
                    refTpmSession.updateChildValues(TpmSessions, withCompletionBlock: { (err, databaseRef) in
                        if err != nil {
                            self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                            return
                        }
                    })
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
                    //Add the new session
                    self.addNewSession()
                }
            }
        }
    }
    
    
    func addNewSession() {
        
        let jumpValue = jumpText.text
        let durationValue = "\(minute).\(seconde)"
        let durationDouble = Double(durationValue)
        let weightDouble = Double(weight)
        let calorieDouble = (7.5*3.5*weightDouble!)/200.0
        let calorie = round(calorieDouble*durationDouble!)
        let calorieValue = String(calorie)
        let altitudeValue = "1"
        
        //Add the new session to a temporary session
        let databaseRef = Database.database().reference(fromURL: "https://jumpin-c4b57.firebaseio.com/")
        let userID = (Auth.auth().currentUser?.uid)!
        let ref = databaseRef.child("sessions").child(userID).child("tmp")
        let tmpSession  = ["altitude": altitudeValue,"duration": durationValue, "calories": calorieValue, "jumps": jumpValue]
        ref.updateChildValues(tmpSession, withCompletionBlock: { (err, databaseRef) in
            self.retrieveSession()
            if err != nil {
                self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                return
            }
        })
    }
    
    //Replace the session 1 by the temporary session
    func retrieveSession() {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("tmp").observeSingleEvent(of: .value)
        { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                let tmpAltitude = dic["altitude"] as? String
                let tmpDuration = dic["duration"] as? String
                let tmpJump = dic["jumps"] as? String
                let tmpCalories = dic["calories"] as? String
                self.replace(altitude: tmpAltitude!, duration: tmpDuration!, jumps: tmpJump!, calories: tmpCalories!)
            }
        }
    }
    
    func replace(altitude: String, duration: String, jumps: String, calories: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        self.ref = Database.database().reference()
        self.ref.child("sessions").child(userID).child("session1").updateChildValues(["altitude": altitude, "duration": duration, "jumps": jumps, "calories": calories])
        
        //Update the counter, incrementation
        let newCounter = Int(self.sessionNb)! + 1
        let counterString = String(newCounter)
        self.ref = Database.database().reference()
        self.ref.child("sessions").child(userID).updateChildValues(["counter": counterString])
        self.redirectionScreen()
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
    
    func alertMissingInfo(title: String, message:String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.destructive, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"InfoViewController") as! InfoViewController
            self.present(viewController, animated: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
