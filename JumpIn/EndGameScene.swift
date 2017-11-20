//
//  EndGameScene.swift
//  JumpIn
//
//  Created by Margaux Dang on 25/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Stars
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: self.size.height-70)
        addChild(star)
        
        let lblStars = SKLabelNode(fontNamed: "Avenir")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: 50, y: self.size.height-80)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        lblStars.text = String(format: "X %d", GameHandler.shareInstance.stars)
        addChild(lblStars)
        
        // Score
        let lblScore = SKLabelNode(fontNamed: "Avenir")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: self.size.width / 2, y: 300)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblScore.text = String(format: "%d", GameHandler.shareInstance.score)
        addChild(lblScore)
        
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "Avenir")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.green
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: 400)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblHighScore.text = String(format: "High Score: %d", GameHandler.shareInstance.highScore)
        addChild(lblHighScore)
        
        //Share button
        //Share button is touched
    
        //Home button
        //Home button is touched
        
        //Replay button
        //Replay button is touched
        
    }
}
