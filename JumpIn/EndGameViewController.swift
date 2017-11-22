//
//  EndGameViewController.swift
//  JumpIn
//
//  Created by Margaux Dang on 22/11/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import UIKit
import Firebase

class EndGameViewController: UIViewController {

    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var jumpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let score = GameHandler.shareInstance.score
        let highscore = GameHandler.shareInstance.highScore
        
        let scoreString = String(score)
        let highScoreString = String(highscore)
        highScoreLabel.text = highScoreString
        scoreLabel.text = scoreString
        
        //Retrieve the number of jumps remaining
        let userID = (Auth.auth().currentUser?.uid)!
    Database.database().reference().child("sessions").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let totalJump = dictionary["totalJump"] as? Int
                let totalString = String(totalJump!)
                self.jumpLabel.text = totalString
            }
        }
    }

    @IBAction func shareButton(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: ["Hi! I just finished a game on JumpIn app, I made a score of \(self.scoreLabel.text!). Try to beat me, my highscore is \(self.highScoreLabel.text!)! 😃"], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func replayButton(_ sender: Any) {
        //Check if the counter is equal to 0
        let userID = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("sessions").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let totalJump = dictionary["totalJump"] as? Int
                self.redirection(counter: totalJump!)
            }
        }
    }
    
    func redirection(counter: Int) {
        if counter == 0 {
            self.createAlert(title: "Error", message: "Sorry, you have to jump again in order to play")
        } else {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let redirect:GameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            self.present(redirect, animated: true, completion: nil)
        }
    }
    
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
