//
//  Enemy.swift
//  Battle Tanks
//
//  Created by Nicholas Looney on 12/5/15.
//  Copyright © 2015 Nicholas Looney. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: UIColor.blackColor(), size: size)
    }
    
    convenience init(pos: CGPoint) {
        let monster = SKSpriteNode(imageNamed: "monster")
        self.init(texture: monster.texture, color: monster.color, size: monster.size)
        self.position = pos
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody!.dynamic = true
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.categoryBitMask = PhysicsCategory.Monster
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Projectile
        self.physicsBody!.collisionBitMask = PhysicsCategory.None
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}