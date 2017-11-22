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
        let activityController = UIActivityViewController(activityItems: ["Hi! I just finished a game on JumpIn app. Try this app! 😃"], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func replayButton(_ sender: Any) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
