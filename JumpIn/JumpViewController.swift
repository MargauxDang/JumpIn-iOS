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
import CoreBluetooth

class JumpViewController: UIViewController {
    
    private var pd = PeripheralDiscoverer.sharedInstance //singleton
    private var selected_peripheral:CBPeripheral?
    
    var jump = 0
    var realjump = 0
    
    var count = 0
    var StartPressed = 0
    
    
    //@IBOutlet var jumpText: UITextField!
    
    @IBOutlet var jumpText: UILabel!
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
    
    let imageName = "TapToStart.png"
    var image: UIImage!
    var imageView: UIImageView!
    
    var total: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.peripheralDiscoveredObs), name:NSNotification.Name(rawValue: kPDNotificationType.newPeripheralsDiscovered.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.peripheralStateChangedObs),
            name:NSNotification.Name(rawValue: kPDNotificationType.peripheralStateChanged.rawValue),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.servicesAndCharacteristicsDiscoveredObs),
            name:NSNotification.Name(rawValue: kPDNotificationType.allServicesAndCharacteristicsDiscovered.rawValue),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.descriptorUpdatedObs),
            name:NSNotification.Name(rawValue: kPDNotificationType.discriptorUpdated.rawValue),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.valueUpdatedObs),
            name:NSNotification.Name(rawValue: kPDNotificationType.valueUpdated.rawValue),
            object: nil)
        
        pausestart.layer.cornerRadius = 10.0
        stop.layer.cornerRadius = 10.0
        timerLabel.text = String(format: "%02d:%02d", minute, seconde)
        
        image = UIImage(named: imageName)
        imageView = UIImageView(image: image!)
        
        imageView.frame = CGRect(x: view.frame.size.width/8, y: view.frame.size.height-250, width: 150, height: 100)
        view.addSubview(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: Notification Handlers
    @objc func peripheralDiscoveredObs(notification: NSNotification){
        print("Yeah!!")
        
        let devices = PeripheralDiscoverer.sharedInstance.discovered_devices
        
        for key:UUID in devices.keys
        {
            if let device_name = devices[key]?.name
            {
                print("Found device:" + device_name)
                
                //If we have found the device we were looking for, then connect..
                if device_name=="BandCizer048"
                {
                    self.selected_peripheral = pd.discovered_devices[key]
                    
                    PeripheralDiscoverer.sharedInstance.central!.connect(self.selected_peripheral!,options: nil)
                    
                }
            }
        }
    }
    
    //MARK: Notification Handlers
    @objc func peripheralStateChangedObs(notification: NSNotification){
        print("peripheralStateChangedObs:")
        
        if let o = notification.object{
            let p = o as! CBPeripheral
            
            print("peripheralStateChangedObs:\(p.state.rawValue)")
            
            switch (p.state){
                
            case .connected:
                print("peripheralStateChangedObs: .connected")
                break
                
            case .disconnected:
                print("peripheralStateChangedObs: .disconnected")
                break
                
                
            case .connecting:
                print("peripheralStateChangedObs: .connecting")
                break
                
            case .disconnecting:
                print("peripheralStateChangedObs: .disconnecting")
                break
                
                
            }
            
        }
    }
    
    
    //TODO: Neat feature -let titles be the human readable description of service/characteristic, if available
    @objc func servicesAndCharacteristicsDiscoveredObs(notification:NSNotification){
        print("servicesAndCharacteristicsDiscoveredObs")
        
        
        if let o = notification.object{
            let p = o as! CBPeripheral
            
            for s:CBService in p.services!{
                
                //Iterate over characteristics in service
                for c in s.characteristics!{
                    
                    
                    print("Found characteristic:" + c.uuid.uuidString)
                    
                    if c.uuid.uuidString=="A2C70031-8F31-11E3-B148-0002A5D5C51B"
                    {//enable notification for specific characteristic
                        p.setNotifyValue(true, for: c)
                    }
                    
                }
            }
        }
    }
    
    //Process descriptors from device: e.g. User Description 0x2901
    //Descriptor UUID's:
    //https://developer.bluetooth.org/gatt/descriptors/Pages/DescriptorsHomePage.aspx
    @objc func descriptorUpdatedObs(notification:NSNotification){
        print("descriptorUpdatedObs")
        
        if let o = notification.object{
            let d = o as! CBDescriptor
            
            if d.uuid == CBUUID(string: "2901") //User description
            {
                print("Human readable description for UUID:" +
                    d.characteristic.uuid.uuidString +
                    " is" +
                    (d.value as! String)
                )
            }
        }
    }
    
    
    @objc func valueUpdatedObs(notification:NSNotification){
        //print("valueUpdatedObs")
        
        if (StartPressed==1)
    {
        if let o = notification.object
        {
            let c = o as! CBCharacteristic
            
            print("length = \((c.value!.count))")
            
            var xvalue: Int = 0
            var yvalue: Int = 0
            var zvalue: Int = 0
            var Avalue: Double = 0
            
            xvalue = c.value!.subdata(in: 2..<4).withUnsafeBytes { $0.pointee }
            yvalue = c.value!.subdata(in: 4..<6).withUnsafeBytes { $0.pointee }
            zvalue = c.value!.subdata(in: 6..<8).withUnsafeBytes { $0.pointee }
            
            if ( xvalue > 32767)
            {
                xvalue = xvalue - 65536
            }
            
            if ( yvalue > 32767)
            {
                yvalue = yvalue - 65536
            }
            
            if ( zvalue > 32767)
            {
                zvalue = zvalue - 65536
            }
            
            Avalue = sqrt((Double)(xvalue*xvalue + yvalue*yvalue + zvalue*zvalue))
            
            print("X value \(xvalue)")
            print("Y value \(yvalue)")
            print("Z value \(zvalue)")
            print("Average value \(Avalue)")
            
            if ( Avalue > 20000 && count == 0 )
            {
                jump = jump + 1
                count = 1
            }
            if (Avalue<10000 )
            {
                count = 0
            }
            
            realjump = (Int)(jump/4)
            print ("number jump \(realjump)")
            self.jumpText.text = (String)(self.realjump)
            
        }
    }
        
}
    
    
    
    //User click on pause
    @IBAction func pause(_ sender: Any) {
        if pause == true {
            pausestart.setTitle(">",for: .normal)
            pause = false
            timer.invalidate()
            StartPressed=0
            
        } else if pause == false {
            
            //If the user didn't put weight/high, have to alert him
            let userID = (Auth.auth().currentUser?.uid)!
            Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                   let high = dictionary["high"] as? String
                   let weight = dictionary["weight"] as? String
                   self.startJumping(high: high!, weight: weight!)
                    self.StartPressed=1
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
        StartPressed=0
        
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
                        self.totalJump(counter: counterString)
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
                    
                    //Create a new variable to calculte the total number of jumps
                    let refTotalJump = databaseRef.child("sessions").child(userID)
                    let totalJump  = ["totalJump":"0"]
                    refTotalJump.updateChildValues(totalJump, withCompletionBlock: { (err, databaseRef) in
                        if err != nil {
                            self.createAlert(title: "Error", message: (err?.localizedDescription)!)
                            return
                        }
                    })
                    
                    self.redirectionScreen()
                }
                
                //If there are at least 1 session
                let counter = Int(self.sessionNb)!
                if (counter>0){
                    
                    //For each records, we decale the session n°
                    for i in (1...counter).reversed() {
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
        
        //Retrieve the counter
        Database.database().reference().child("sessions").child(userID).observeSingleEvent(of: .value)
        { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                let counter = dic["counter"] as? String
                self.redirectionScreen()
                self.totalJump(counter: counter!)
            }
        }
        
    }
    
    func totalJump(counter: String) {
        let counterInt = Int(counter)
        for i in 1...counterInt! {
            let userID = (Auth.auth().currentUser?.uid)!
            Database.database().reference().child("sessions").child(userID).child("session\(i)").observeSingleEvent(of: .value)
            { (snapshot) in
                if let dic = snapshot.value as? [String: AnyObject] {
                    let jump = dic["jumps"] as? String
                    let jumpInt = Int(jump!)
                    self.total = self.total + (jumpInt!)
                    
                    if i == counterInt! {
                        self.updateTotalJump(total: self.total)
                    }
                }
            }
        }
    }
    
    func updateTotalJump(total: Int) {
        let userID = (Auth.auth().currentUser?.uid)!
        ref = Database.database().reference()
        ref.child("sessions").child(userID).updateChildValues(["totalJump": total])
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
