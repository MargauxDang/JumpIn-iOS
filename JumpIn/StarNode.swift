//
//  StarNode.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import SpriteKit

enum StarType:Int {
    case NormalStar = 0
    case specialStar = 1
}

class StarNode: GameObjectNode {
    var starType:StarType!
    override func collisionWithPlayer(player: SKNode) -> Bool {
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 300)
        
        //Normal star = 20 pts to the score
        //Special star = 100 pts to the score
        GameHandler.shareInstance.score += (starType == StarType.NormalStar ? 20 : 100)
        
        //Normal star = 1 to the nb of stars
        //Special star = 5 to the nb of stars
        GameHandler.shareInstance.stars += (starType == StarType.NormalStar ? 1 : 5)

        self.removeFromParent()
        return true
    }
}
