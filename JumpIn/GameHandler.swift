//
//  GameHandler.swift
//  JumpIn
//
//  Created by Margaux Dang on 25/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class GameHandler {
    var score:Int
    var highScore: Int
    var stars:Int
    var savedHighScore:String!
    
    var levelData: NSDictionary!
    
    class var shareInstance:GameHandler {
        struct Sigleton {
            static let instance = GameHandler()
        }
        return Sigleton.instance
    }
    
    init() {
        score = 0
        highScore = 0
        stars = 0

        let userDefaults = UserDefaults.standard
        highScore = userDefaults.integer(forKey: "highScore")
        stars = userDefaults.integer(forKey: "stars")
        
        if let path = Bundle.main.path(forResource: "Level01", ofType: "plist") {
            if let level = NSDictionary(contentsOfFile: path) {
                levelData = level
            }
        }
    }
    
    func saveGameScore() {
        highScore = max(score, highScore)
        let userDefaults = UserDefaults.standard
        userDefaults.set(highScore, forKey: "highScore")
        userDefaults.set(stars, forKey: "stars")
        userDefaults.synchronize()
    }
}
