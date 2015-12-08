//
//  Player.swift
//  Battle Tanks
//
//  Created by Nicholas Looney on 12/7/15.
//  Copyright © 2015 Nicholas Looney. All rights reserved.
//

import Foundation
import SpriteKit

//class Player: SKSpriteNode {
//    
//    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
//        super.init(texture: nil, color: UIColor.blackColor(), size: size)
//    }
//    
//    convenience init(pos: CGPoint) {
//        let player = SKSpriteNode(imageNamed: "player")
//        self.init(texture: player.texture, color: player.color, size: player.size)
//        self.position = pos
//        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
//        self.physicsBody!.dynamic = true
//        self.physicsBody!.affectedByGravity = false
//        self.physicsBody!.categoryBitMask = PhysicsCategory.Player
//        self.physicsBody!.contactTestBitMask = PhysicsCategory.None
//        self.physicsBody!.collisionBitMask = PhysicsCategory.Walls
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}