//
//  Walls.swift
//  Battle Tanks
//
//  Created by Nicholas Looney on 11/29/15.
//  Copyright © 2015 Nicholas Looney. All rights reserved.
//

import SpriteKit

//class Walls: SKShapeNode {
//    
//    override init(rectOfSize: CGSize) {
//        super.init(texture: nil, color: UIColor.blackColor(), size: CGSize)
//    }
//    
//    convenience init(pos: CGPoint, rectOfSize size: CGSize) {
//        let rectangle = SKShapeNode(rectOfSize: CGSize(width:390, height:200))
//        self.init: (rectOfSize size: CGSize)
//        rectangle.position = pos
//        rectangle.rectOfSize = size
//        rectangle.strokeColor = SKColor.blackColor()
//        rectangle.glowWidth = 1.0
//        rectangle.physicsBody = SKPhysicsBody(edgeChainFromPath: rectangle.path!)
//        rectangle.physicsBody?.dynamic = false
//        rectangle.physicsBody?.categoryBitMask = PhysicsCategory.Walls
//        rectangle.physicsBody?.contactTestBitMask = PhysicsCategory.None
//        rectangle.physicsBody?.collisionBitMask = PhysicsCategory.All
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}