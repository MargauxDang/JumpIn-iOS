//
//  GameElements.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    //Background
    func createBackgroundNode() -> SKNode {
        let backgroundNode = SKNode()
        let ySpacing = 64.0 * scaleFactor
        for index in 0...19 {
            let node = SKSpriteNode(imageNamed:String(format: "Background%02d", index + 1))
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: self.size.width / 2, y: ySpacing * CGFloat(index))
            backgroundNode.addChild(node)
        }
        return backgroundNode
    }
    
    //Player
    func createPlayer() -> SKNode {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: 80.0)
        
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        
        //Gravity
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        //Collision
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform
        
        return playerNode
    }
    
    //Plateform
    func createPlateformAtPosition(position: CGPoint, ofType type:PlateformType) -> PlateformNode {
        let node = PlateformNode()
        let position = CGPoint(x:position.x * scaleFactor, y: position.y)
        node.position = position
        node.name = "PLATEFORMNODE"
        node.plateformType = type
        
        var sprite:SKSpriteNode
        if type == PlateformType.normalBrick {
            sprite = SKSpriteNode(imageNamed: "Platform")
        } else {
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        }
        
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    //Star
    func createStarAtPosition(position: CGPoint, ofType type:StarType) -> StarNode {
        let node = StarNode()
        let position = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = position
        node.name = "STARMODE"
        node.starType = type
        
        var sprite: SKSpriteNode
        
        if type == StarType.NormalStar {
            sprite = SKSpriteNode(imageNamed: "Star")
        } else {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        }
        
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0
        return node
    }
}
