//
//  DetailViewController.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 8/14/17.
//

import UIKit
import Firebase
import FirebaseDatabase

class DetailViewController: UIViewController {
    var chartName: String?
    var session1: String!
    var session2: String!
    var session3: String!
    var session4: String!
    var session5: String!
    var session6: String!
    var session7: String!
    var session8: String!
    var session9: String!
    var session10: String!
    
    @IBOutlet var warningText: UIButton!
    var ref:DatabaseReference!
    let loadingTextLabel = UILabel()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()


    @IBOutlet var session1txt: UIButton!
    @IBOutlet var session2txt: UIButton!
    @IBOutlet var session3txt: UIButton!
    @IBOutlet var session4txt: UIButton!
    @IBOutlet var session5txt: UIButton!
    @IBOutlet var session6txt: UIButton!
    @IBOutlet var session7txt: UIButton!
    @IBOutlet var session8txt: UIButton!
    @IBOutlet var session9txt: UIButton!
    @IBOutlet var session10txt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _chartName = self.chartName else {
            print("Invalid Chart Name")
            return
        }
        
        self.title = _chartName
        
        switch _chartName {
        case "Calories":
            printSession1(activity: "calories")
        case "Jumps":
            printSession1(activity: "jumps")
        case "Duration":
            printSession1(activity: "duration")
        default:
            break
        }
    }
    
    
    //Display all data
    private func printSession1(activity: String) {
        
        let userID = (Auth.auth().currentUser?.uid)!
        let databaseRef = Database.database().reference(fromURL: "https://jumpin-c4b57.firebaseio.com/")
        databaseRef.child("sessions").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild("session1"){
                self.warningText.setTitle("You need to do, at least, one session", for: .normal)
            }
        })
        
        Database.database().reference().child("sessions").child(userID).child("session1").observeSingleEvent(of: .value) { (snapshot) in
                if let userDict = snapshot.value as? [String:Any] {
                    self.session1txt.setTitle(userDict[activity] as? String, for: .normal)
                    self.session1 = userDict[activity] as? String
                    
                    // If the user never did session, we just print a message
                    if (self.session1 != "0") {
                        //Waiting message
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        self.loadingTextLabel.text = "Wait please, loading..."
                        self.loadingTextLabel.font = UIFont(name: "Avenir Light", size: 12)
                        self.loadingTextLabel.sizeToFit()
                        self.loadingTextLabel.center = CGPoint(x: self.activityIndicator.center.x, y: self.activityIndicator.center.y + 30)
                        self.view.addSubview(self.loadingTextLabel)
                    }
                    
                    self.printSession2(activity: activity, session1: self.session1)
                }
            }
        }
    
    private func printSession2(activity: String, session1: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session2").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session2txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session2 = userDict[activity] as? String
                self.printSession3(activity: activity, session1: session1, session2: self.session2)
            }
        }
    }
    
    private func printSession3(activity: String, session1: String, session2: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session3").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session3txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session3 = userDict[activity] as? String
                self.printSession4(activity: activity, session1: session1, session2: session2, session3: self.session3)
            }
        }
    }
    
    private func printSession4(activity: String, session1: String, session2: String, session3: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session4").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session4txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session4 = userDict[activity] as? String
                self.printSession5(activity: activity, session1: session1, session2: session2, session3: session3, session4: self.session4)
            }
        }
    }
    
    private func printSession5(activity: String, session1: String, session2: String, session3: String, session4: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session5").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session5txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session5 = userDict[activity] as? String
                self.printSession6(activity: activity, session1: session1, session2: session2, session3: session3, session4: session4, session5: self.session5)
            }
        }
    }
    
    private func printSession6(activity: String, session1: String, session2: String, session3: String, session4: String, session5: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session6").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session6txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session6 = userDict[activity] as? String
                self.printSession7(activity: activity, session1: session1, session2: session2, session3: session3, session4: session4, session5: session5, session6: self.session6)
            }
        }
    }
    
    private func printSession7(activity: String, session1: String, session2: String, session3: String, session4: String, session5: String, session6: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session7").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session7txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session7 = userDict[activity] as? String
                self.printSession8(activity: activity, session1: session1, session2: session2, session3: session3, session4: session4, session5: session5, session6: session6, session7: self.session7)
            }
        }
    }
    
    private func printSession8(activity: String, session1: String, session2: String, session3: String, session4: String, session5: String, session6: String, session7: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session8").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session8txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session8 = userDict[activity] as? String
                self.printSession9(activity: activity, session1: session1, session2: session2, session3: session3, session4: session4, session5: session5, session6: session6, session7: session7, session8: self.session8)
            }
        }
    }
    
    private func printSession9(activity: String, session1: String, session2: String, session3: String, session4: String, session5: String, session6: String, session7: String, session8: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session9").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session9txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session9 = userDict[activity] as? String
                self.printSession10(activity: activity, session1: session1, session2: session2, session3: session3, session4: session4, session5: session5, session6: session6, session7: session7, session8: session8, session9: self.session9)
            }
        }
    }
    
    private func printSession10(activity: String, session1: String, session2: String, session3: String, session4: String, session5: String, session6: String, session7: String, session8: String, session9: String) {
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).child("session10").observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                self.session10txt.setTitle(userDict[activity] as? String, for: .normal)
                self.session10 = userDict[activity] as? String
                self.setChart(activity: activity, session1: session1, session2: session2, session3: session3, session4: session4, session5: session5, session6: session6, session7: session7, session8: session8, session9: session9, session10: self.session10)
            }
        }
    }
    
    //Draw the bar charts
    private func setChart(activity: String, session1: String, session2: String, session3: String, session4: String, session5: String, session6: String, session7: String, session8: String, session9: String, session10: String) {
        
        if session1 != "0" {
        //Initialize string to CGPloat
        guard let sess1 = NumberFormatter().number(from: session1) else { return }
        guard let sess2 = NumberFormatter().number(from: session2) else { return }
        guard let sess3 = NumberFormatter().number(from: session3) else { return }
        guard let sess4 = NumberFormatter().number(from: session4) else { return }
        guard let sess5 = NumberFormatter().number(from: session5) else { return }
        guard let sess6 = NumberFormatter().number(from: session6) else { return }
        guard let sess7 = NumberFormatter().number(from: session7) else { return }
        guard let sess8 = NumberFormatter().number(from: session8) else { return }
        guard let sess9 = NumberFormatter().number(from: session9) else { return }
        guard let sess10 = NumberFormatter().number(from: session10) else { return }
        
        let barChart = PNBarChart(frame: CGRect(x: 0, y: 50, width: 320, height: 200))
        barChart.backgroundColor = UIColor.clear
        barChart.animationType = .Waterfall
        barChart.labelMarginTop = 5.0
        barChart.xLabels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10" ]
        barChart.yValues = [CGFloat(sess1),CGFloat(sess2),CGFloat(sess3),CGFloat(sess4),CGFloat(sess5),CGFloat(sess6),CGFloat(sess7),CGFloat(sess8),CGFloat(sess9), CGFloat(sess10)]
        barChart.strokeChart()
        barChart.center = self.view.center
        self.view.addSubview(barChart)
        
        //Dismiss message
        loadingTextLabel.text = ""
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
