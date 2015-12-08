//
//  GameOverScene.swift
//  Battle Tanks
//
//  Created by Nicholas Looney on 11/10/15.
//  Copyright © 2015 Nicholas Looney. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.whiteColor()
        
        let message = won ? "You Win" : "You Lose"
//        var message: String
//        if won == true {
//            message = "You Won!"
//        }
//        else if won == false {
//            message = "You Lose :["
//        }
        
        let label = SKLabelNode(fontNamed: "Ariel")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        scaleMode = SKSceneScaleMode.AspectFill
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}