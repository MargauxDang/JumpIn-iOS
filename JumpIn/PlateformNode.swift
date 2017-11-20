//
//  PlateformNode.swift
//  JumpIn
//
//  Created by Margaux Dang on 17/10/2017.
//  Copyright © 2017 Margaux Dang. All rights reserved.
//

import SpriteKit

class PlateformNode: GameObjectNode {
    var plateformType:PlateformType!
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        if Int((player.physicsBody?.velocity.dy)!) < 0 {
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 250)
            
            // To go more in deep, we can add a breakable condition
            if plateformType == PlateformType.breakableBrick {
                self.removeFromParent()
            }
        }
        return false
    }
}
