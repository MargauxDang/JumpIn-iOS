//
//  GameScene.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    //Variables
    var backgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    var player: SKNode!
    var scaleFactor: CGFloat!
    let tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0.0
    var currentMaxY:Int!
    var scoreLabel:SKLabelNode!
    var starLabel:SKLabelNode!
    var playersMaxY:Int!
    var gameOver = false
    var endLevelY = 0

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Initialization
    override init(size: CGSize) {
        super.init(size: size)
        scaleFactor = self.size.width / 320.0
        
        let levelData = GameHandler.shareInstance.levelData

        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
       
        foregroundNode = SKNode()
        addChild(foregroundNode)
        
        player = createPlayer()
        foregroundNode.addChild(player)
        
        
        let platforms = levelData!["Platforms"] as! NSDictionary
        let platformPatterns = platforms["Patterns"] as! NSDictionary
        let platformPositions = platforms["Positions"] as! [NSDictionary]
        
        for platformPosition in platformPositions {
            let x = (platformPosition["x"] as AnyObject).floatValue
            let y = (platformPosition["y"] as AnyObject).floatValue
            let pattern = platformPosition["pattern"] as! NSString
            
            let platformPattern = platformPatterns[pattern] as! [NSDictionary]
            for platformPoint in platformPattern {
                let xValue = (platformPoint["x"] as AnyObject).floatValue
                let yValue = (platformPoint["y"] as AnyObject).floatValue
                let type = PlateformType(rawValue: (platformPoint["type"]! as AnyObject).integerValue)
                let xPosition = CGFloat(xValue! + x!)
                let yPosition = CGFloat(yValue! + y!)
                
                let platformNode = createPlateformAtPosition(position: CGPoint(x: xPosition, y: yPosition), ofType: type!)
                foregroundNode.addChild(platformNode)
            }
        }
        
        let stars = levelData!["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]
        
        for starPosition in starPositions {
            let x = (starPosition["x"] as AnyObject).floatValue
            let y = (starPosition["y"] as AnyObject).floatValue
            let pattern = starPosition["pattern"] as! NSString
            
            let starPattern = starPatterns[pattern] as! [NSDictionary]
            for starPoint in starPattern {
                let xValue = (starPoint["x"] as AnyObject).floatValue
                let yValue = (starPoint["y"] as AnyObject).floatValue
                let type = StarType(rawValue: (starPoint["type"]! as AnyObject).integerValue)
                let xPosition = CGFloat(xValue! + x!)
                let yPosition = CGFloat(yValue! + y!)
                
                let starNode = createStarAtPosition(position: CGPoint(x: xPosition, y: yPosition), ofType: type!)
                foregroundNode.addChild(starNode)
            }
        }
        
        
        let star = createStarAtPosition(position: CGPoint(x:160,y:220), ofType: StarType.NormalStar)
        foregroundNode.addChild(star)
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self
        
        //Tap to start
        hudNode = SKNode()
        addChild(hudNode)
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180.0)
        hudNode.addChild(tapToStartNode)
        
        //Motion manager
        motionManager.accelerometerUpdateInterval = 0.2
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {(accelData: CMAccelerometerData!, errorOC: Error!) in
            let acceleration = accelData.acceleration
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
        })
        
        //When the game is finish//
        currentMaxY = 80
        GameHandler.shareInstance.score = 0
        gameOver = false
        endLevelY = (levelData!["EndY"]! as AnyObject).integerValue
        
        //Scores
        let starScore = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: self.size.height-30)
        hudNode.addChild(starScore)

        starLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        starLabel.fontSize = 30
        starLabel.fontColor = SKColor.white
        starLabel.position = CGPoint(x: 50, y: self.size.height-40)
        starLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
 
        //starLabel.text = "\(GameHandler.shareInstance.stars)"
        hudNode.addChild(starLabel)
        
        starLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        starLabel.fontSize = 30
        starLabel.fontColor = SKColor.white
        starLabel.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
        starLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right

        //starLabel.text = "0"
        hudNode.addChild(starLabel)
        
    } //End init
    
    //Manage collision
    func didBegin(_ contact: SKPhysicsContact) {
        var updateHud = false
        var otherNode:SKNode!
        
        if contact.bodyA.node != player{
            otherNode = contact.bodyA.node
        } else {
            otherNode = contact.bodyB.node
        }
        
        updateHud = (otherNode as! GameObjectNode).collisionWithPlayer(player: player)
        if updateHud {
            //starLabel.text = "\(GameHandler.shareInstance.stars)"
            //scoreLabel.text = "\(GameHandler.shareInstance.score)"
        }
    }
    
    //Manipulate the velocity of the player
    override func didSimulatePhysics() {
        player.physicsBody?.velocity = CGVector(dx: xAcceleration * 400.0, dy: player.physicsBody!.velocity.dy)
        
        //If the player is out of the screen by the left or the right, he can appeared by the right or left
        if player.position.x < -20.0 {
            player.position = CGPoint(x: self.size.width + 20.0, y: player.position.y)
        } else if (player.position.x > self.size.width + 20.0) {
            player.position = CGPoint(x: -20.0, y: player.position.y)
        }
    }

    //Tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapToStartNode.removeFromParent()
        player.physicsBody?.isDynamic = true
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0)) //Boost
        
    }
    
    //Parallaxalization effect : move "to a screen to another"
    override func update(_ currentTime: CFTimeInterval) {
        if gameOver {
            return
        }
        
        foregroundNode.enumerateChildNodes(withName: "PLATEFORMNODE") { (node, stop) in
            let platform = node as! PlateformNode
            platform.checkNodeRemoval(playerY: self.player.position.y)
        }
        
        foregroundNode.enumerateChildNodes(withName: "STARMODE") { (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(playerY: self.player.position.y)
        }
        
        if player.position.y > 200 {
            backgroundNode.position = CGPoint(x: 0, y: -((player.position.y - 200)/10))
            foregroundNode.position = CGPoint(x: 0, y: -(player.position.y - 200))
        }
        
        //Increase the score when the player travels up the screen
        if Int(player.position.y) > currentMaxY {
            GameHandler.shareInstance.score += Int(player.position.y) - currentMaxY
            currentMaxY = Int(player.position.y)
            //scoreLabel.text = "\(GameHandler.shareInstance.score)"
        }
        
        //Check if we've finished the level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        
        // Check if we've fallen too far
        if Int(player.position.y) < currentMaxY - 200 {
            endGame()
        }
        
    }
    
    func endGame() {
        gameOver = true
        GameHandler.shareInstance.saveGameScore()
        let transition = SKTransition.fade(withDuration: 0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view!.presentScene(endGameScene, transition: transition)
    }

}
