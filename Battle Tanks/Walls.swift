//
//  Walls.swift
//  Battle Tanks
//
//  Created by Nicholas Looney on 11/29/15.
//  Copyright © 2015 Nicholas Looney. All rights reserved.
//

import SpriteKit

//class Walls: SKSpriteNode {
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        didLoad()
//    }
//    
//    func didLoad() {
//        let rectangle = SKShapeNode(rectOfSize: CGSize(width:390, height:200))
//        rectangle.position = CGPointMake(frame.midX-10, frame.midY + 50)
//        rectangle.strokeColor = SKColor.blackColor()
//        rectangle.glowWidth = 1.0
//        rectangle.physicsBody = SKPhysicsBody(edgeChainFromPath: rectangle.path!)
//        rectangle.physicsBody?.dynamic = false
//        rectangle.physicsBody?.categoryBitMask = PhysicsCategory.Walls
//        rectangle.physicsBody?.contactTestBitMask = PhysicsCategory.None
//        rectangle.physicsBody?.collisionBitMask = PhysicsCategory.All
//    }
//}