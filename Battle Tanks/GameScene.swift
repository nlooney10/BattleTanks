//
//  GameScene.swift
//  Battle Tanks
//
//  Created by Nicholas Looney on 11/9/15.
//  Copyright (c) 2015 Nicholas Looney. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
    static let Walls     : UInt32 = 0b11
    static let Player    : UInt32 = 0b100
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

infix operator ** { associativity left precedence 160 }
func ** (left: CGFloat, right: CGFloat) -> CGFloat! {
    return pow(left, right)
}
infix operator **= { associativity right precedence 90 }
func **= (inout left: CGFloat, right: CGFloat) {
    left = left ** right
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player = SKSpriteNode(imageNamed: "player")
    let buttonDirUp1 = ControllerButton(imageNamed: "button_dir_up_0", position: CGPoint(x: 100, y: 150))
    let buttonDirUp2 = ControllerButton(imageNamed: "button_dir_up_0", position: CGPoint(x: 550, y: 150))
    let buttonDirLeft1 = ControllerButton(imageNamed: "button_dir_left_0", position: CGPoint(x: 50, y: 100))
    let buttonDirLeft2 = ControllerButton(imageNamed: "button_dir_left_0", position: CGPoint(x: 500, y: 100))
    let buttonDirDown1 = ControllerButton(imageNamed: "button_dir_down_0", position: CGPoint(x: 100, y: 50))
    let buttonDirDown2 = ControllerButton(imageNamed: "button_dir_down_0",position: CGPoint(x: 550, y: 50))
    let buttonDirRight1 = ControllerButton(imageNamed: "button_dir_right_0",position: CGPoint(x: 150, y: 100))
    let buttonDirRight2 = ControllerButton(imageNamed: "button_dir_right_0",position: CGPoint(x: 600, y: 100))
    
    var pressedButtons1 = [SKSpriteNode]()
    var pressedButtons2 = [SKSpriteNode]()
    var monstersDestroyed = 0
    var shooting = false
    var lastShootingTime: CFTimeInterval = 0
    var delayBetweenShots: CFTimeInterval = 0.5
    var shooter: NSTimer?
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = SKSceneScaleMode.AspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.grayColor()
        //let bgimage = SKSpriteNode(imageNamed: "dirt.jpg")
        //self.addChild(bgimage)
        //bgimage.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        //let player = Player(pos: CGPoint(x: size.width * 0.3, y: size.height * 0.7))
        player.position = CGPoint(x: size.width * 0.3, y: size.height * 0.7)
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        // Physics engine will not control movement of monster, your code will
        player.physicsBody?.dynamic = true
        // Set category of bitmask
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        // Indicates what categories of objects this object should notify the contact listener when they intersect
        player.physicsBody?.contactTestBitMask = PhysicsCategory.None
        // Indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of)
        player.physicsBody?.collisionBitMask = PhysicsCategory.Walls
        player.physicsBody?.allowsRotation = false
        addChild(player)
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(3.0)
                ])
            ))
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        let rectangle = SKShapeNode(rectOfSize: CGSize(width:390, height:200))
        rectangle.position = CGPointMake(frame.midX-10, frame.midY + 50)  //Middle of Screen
        rectangle.strokeColor = SKColor.blackColor()
        rectangle.glowWidth = 1.0
        
        rectangle.physicsBody = SKPhysicsBody(edgeLoopFromPath: rectangle.path!)
        // Physics engine will not control movement of monster, your code will
        rectangle.physicsBody?.dynamic = false
        // Set category of bitmask
        rectangle.physicsBody?.categoryBitMask = PhysicsCategory.Walls
        // Indicates what categories of objects this object should notify the contact listener when they intersect
        rectangle.physicsBody?.contactTestBitMask = PhysicsCategory.None
        // Indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of)
        rectangle.physicsBody?.collisionBitMask = PhysicsCategory.All
        self.addChild(rectangle)
        
        let line = SKShapeNode(rectOfSize: CGSize(width: 0, height: 50))
        line.position = CGPointMake(frame.midX-10, frame.midY + 50)
        line.strokeColor = SKColor.blackColor()
        line.glowWidth = 1.0
        
        line.physicsBody = SKPhysicsBody(edgeLoopFromPath: rectangle.path!)
        line.physicsBody?.dynamic = false
        line.physicsBody?.categoryBitMask = PhysicsCategory.Walls
        line.physicsBody?.contactTestBitMask = PhysicsCategory.None
        line.physicsBody?.collisionBitMask = PhysicsCategory.All
        self.addChild(line)
        
        buttonDirUp1.alpha = 0.2
        self.addChild(buttonDirUp1)
        
        buttonDirUp2.alpha = 0.2
        self.addChild(buttonDirUp2)
        
        buttonDirLeft1.alpha = 0.2
        self.addChild(buttonDirLeft1)
        
        buttonDirLeft2.alpha = 0.2
        self.addChild(buttonDirLeft2)
        
        buttonDirDown1.alpha = 0.2
        self.addChild(buttonDirDown1)
        
        buttonDirDown2.alpha = 0.2
        self.addChild(buttonDirDown2)
        
        buttonDirRight1.alpha = 0.2
        self.addChild(buttonDirRight1)
        
        buttonDirRight2.alpha = 0.2
        self.addChild(buttonDirRight2)
        
        let l = 94.0 as CGFloat // Radius of Circle
        let l1 = 94.0 as CGFloat
        let x0 = 90.0 as CGFloat
        let x1 = 550.0 as CGFloat
        let y0 = 100.0 as CGFloat
        let y1 = 100.0 as CGFloat
        // tangent of 60 degrees angle
        let angle = CGFloat(tan(M_PI / 3))
        
        // hitboxes are within a range of 0~4.0 pixels and angles of -60~60 degrees
        buttonDirUp1.hitbox = {
            (location: CGPoint) -> Bool in
            let is_above_y0 = location.y - y0 > 0
            let is_within_angle = (abs(location.x - x0) <= abs(location.y - y0) * angle)
            let is_within_radius = (location.x - x0) ** 2 + (location.y - y0) ** 2 <= l ** 2
            return is_above_y0 && is_within_angle && is_within_radius
        }
        // Right
        buttonDirUp2.hitbox = {
            (location: CGPoint) -> Bool in
            let is_above_y1 = location.y - y1 > 0
            let is_within_angle = (abs(location.x - x1) <= abs(location.y - y1) * angle)
            let is_within_radius = (location.x - x1) ** 2 + (location.y - y1) ** 2 <= l1 ** 2
            return is_above_y1 && is_within_angle && is_within_radius
        }
        buttonDirLeft1.hitbox = {
            (location: CGPoint) -> Bool in
            let is_left_of_x0 = location.x - x0 < 0
            let is_within_angle = (abs(location.x - x0) * angle >= abs(location.y - y0))
            let is_within_radius = (location.x - x0) ** 2 + (location.y - y0) ** 2 <= l ** 2
            return is_left_of_x0 && is_within_angle && is_within_radius
        }
        // Right
        buttonDirLeft2.hitbox = {
            (location: CGPoint) -> Bool in
            let is_left_of_x1 = location.x - x1 < 0
            let is_within_angle = (abs(location.x - x1) * angle >= abs(location.y - y1))
            let is_within_radius = (location.x - x1) ** 2 + (location.y - y1) ** 2 <= l1 ** 2
            return is_left_of_x1 && is_within_angle && is_within_radius
        }
        buttonDirDown1.hitbox = {
            (location: CGPoint) -> Bool in
            let is_below_of_y0 = location.y - y0 < 0
            let is_within_angle = (abs(location.x - x0) <= abs(location.y - y0) * angle)
            let is_within_radius = (location.x - x0) ** 2 + (location.y - y0) ** 2 <= l ** 2
            return is_below_of_y0 && is_within_angle && is_within_radius
        }
        // Right
        buttonDirDown2.hitbox = {
            (location: CGPoint) -> Bool in
            let is_below_of_y1 = location.y - y1 < 0
            let is_within_angle = (abs(location.x - x1) <= abs(location.y - y1) * angle)
            let is_within_radius = (location.x - x1) ** 2 + (location.y - y1) ** 2 <= l1 ** 2
            return is_below_of_y1 && is_within_angle && is_within_radius
        }
        buttonDirRight1.hitbox = {
            (location: CGPoint) -> Bool in
            let is_right_of_x0 = location.x - x0 > 0
            let is_within_angle = (abs(location.x - x0) * angle >= abs(location.y - y0))
            let is_within_radius = (location.x - x0) ** 2 + (location.y - y0) ** 2 <= l ** 2
            return is_right_of_x0 && is_within_angle && is_within_radius
        }
        // Right
        buttonDirRight2.hitbox = {
            (location: CGPoint) -> Bool in
            let is_right_of_x1 = location.x - x1 > 0
            let is_within_angle = (abs(location.x - x1) * angle >= abs(location.y - y1))
            let is_within_radius = (location.x - x1) ** 2 + (location.y - y0) ** 2 <= l1 ** 2
            return is_right_of_x1 && is_within_angle && is_within_radius
        }
        
//        let backgroundMusic = SKAudioNode(fileNamed: "Chugging Along.mp3")
//        backgroundMusic.autoplayLooped = true
//        SKAction.changeVolumeTo(0.1, duration: 0)
//        addChild(backgroundMusic)
        
// This is how to pan audio
//        let music = SKAudioNode(fileNamed: "Chugging Along.mp3")
//        addChild(music)
//        
//        music.positional = true
//        music.position = CGPoint(x: -1024, y: 0)
//        
//        let moveForward = SKAction.moveToX(1024, duration: 2)
//        let moveBack = SKAction.moveToX(-1024, duration: 2)
//        let sequence = SKAction.sequence([moveForward, moveBack])
//        let repeatForever = SKAction.repeatActionForever(sequence)
//        
//        music.runAction(repeatForever)
        
        print(self.size)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for button in [buttonDirUp1, buttonDirLeft1, buttonDirDown1, buttonDirRight1] {
                // Check if they are already registered in the list
                if button.hitboxContainsPoint(location) && pressedButtons1.indexOf(button) == nil {
                    pressedButtons1.append(button)
                    print("left buttons tapped \(location)")
                }
            }
            for button in [buttonDirUp2, buttonDirLeft2, buttonDirDown2, buttonDirRight2] {
                // Check if they are already registered in the list
                if button.hitboxContainsPoint(location) && pressedButtons2.indexOf(button) == nil {
                    pressedButtons2.append(button)
                    print("right buttons tapped \(location)")
                    self.shooter = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "shoot", userInfo: nil, repeats: true)
                    self.shooter!.fire()
                }
            }
        }
        // Check all the 4 buttons and set the transparency
        for button in [buttonDirUp1, buttonDirLeft1, buttonDirDown1, buttonDirRight1] {
            if pressedButtons1.indexOf(button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
        for button in [buttonDirUp2, buttonDirLeft2, buttonDirDown2, buttonDirRight2] {
            if pressedButtons2.indexOf(button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            
            for button in [buttonDirDown1, buttonDirLeft1, buttonDirRight1, buttonDirUp1] {
                // If you take your finger off the button you had it on
                if button.hitboxContainsPoint(previousLocation) && !button.hitboxContainsPoint(location) {
                    let index = pressedButtons1.indexOf(button)
                    if index != nil {
                        pressedButtons1.removeAtIndex(index!)
                    }
                }
                // If you move from one button to another without lifting
                else if !button.hitboxContainsPoint(previousLocation) && button.hitboxContainsPoint(location) && pressedButtons2.indexOf(button) == nil {
                        pressedButtons1.append(button)
                }
            }
            
            for button in [buttonDirDown2, buttonDirLeft2, buttonDirRight2, buttonDirUp2] {
                // If you take your finger off the button you had it on
                if button.hitboxContainsPoint(previousLocation) && !button.hitboxContainsPoint(location) {
                    let index = pressedButtons2.indexOf(button)
                    if index != nil {
                        pressedButtons2.removeAtIndex(index!)
                    }
                }
                    // If you move from one button to another without lifting
                else if !button.hitboxContainsPoint(previousLocation) && button.hitboxContainsPoint(location) && pressedButtons2.indexOf(button) == nil {
                    pressedButtons2.append(button)
                }
            }
        }
        for button in [buttonDirUp1, buttonDirLeft1, buttonDirDown1, buttonDirRight1] {
            if pressedButtons1.indexOf(button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
        for button in [buttonDirUp2, buttonDirLeft2, buttonDirDown2, buttonDirRight2] {
            if pressedButtons2.indexOf(button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = Enemy(pos: CGPoint(x: size.width * 0.7, y: size.height * 0.7))
        addChild(monster)
        
        // Create the actions
        //let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        //let actionMoveDone = SKAction.removeFromParent()
//        let loseAction = SKAction.runBlock() {
//            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
//        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        //monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesEndedOrCancelled(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEndedOrCancelled(touches, withEvent: event)
    }
    
    func touchesEndedOrCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        for touch: AnyObject in touches! {
            let location = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            
            for button in [buttonDirUp1, buttonDirLeft1, buttonDirDown1, buttonDirRight1] {
                if button.hitboxContainsPoint(location) {
                    let index = pressedButtons1.indexOf(button)
                    if index != nil {
                        pressedButtons1.removeAtIndex(index!)
                    }
                }
                else if (button.hitboxContainsPoint(previousLocation)) {
                    let index = pressedButtons1.indexOf(button)
                    if index != nil {
                        pressedButtons1.removeAtIndex(index!)
                    }
                }
            }
            for button in [buttonDirUp2, buttonDirLeft2, buttonDirDown2, buttonDirRight2] {
                if button.hitboxContainsPoint(location) {
                    let index = pressedButtons2.indexOf(button)
                    if index != nil {
                        pressedButtons2.removeAtIndex(index!)
                        if let shooter = self.shooter {
                            shooter.invalidate()
                        }
                    }
                }
                else if (button.hitboxContainsPoint(previousLocation)) {
                    let index = pressedButtons2.indexOf(button)
                    if index != nil {
                        pressedButtons2.removeAtIndex(index!)
                        if let shooter = self.shooter {
                            shooter.invalidate()
                        }
                    }
                }
            }
        }
        for button in [buttonDirUp1, buttonDirLeft1, buttonDirDown1, buttonDirRight1] {
            if pressedButtons1.indexOf(button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
        for button in [buttonDirUp2, buttonDirLeft2, buttonDirDown2, buttonDirRight2] {
            if pressedButtons2.indexOf(button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        runAction(SKAction.playSoundFileNamed("Blast.mp3", waitForCompletion: false))
        projectile.removeFromParent()
        monster.removeFromParent()
        monstersDestroyed++
        if (monstersDestroyed >= 1) {
            //let delay = SKAction.waitForDuration(1.0)
            //let transistion = SKAction.runBlock() {
                let reveal = SKTransition.flipHorizontalWithDuration(0.2)
                let gameOverScene = GameOverScene(size: self.size, won: true)
                self.view?.presentScene(gameOverScene, transition: reveal)
            //}
            //SKAction.sequence([transistion])
        }
    }
    
    func monsterDidCollideWithWall(monster:SKSpriteNode, wall:SKShapeNode) {
        monster.removeFromParent()
    }
    
    func projectileDidCollideWithWall(projectile:SKSpriteNode, wall:SKShapeNode) {
        projectile.removeFromParent()
    }
    
    // Gets called by the contact delegate (i.e. the scene) when two things collide
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.Walls != 0)) {
            if let firstNode = firstBody.node as? SKSpriteNode, secondNode = secondBody.node as? SKShapeNode {
                monsterDidCollideWithWall(firstNode, wall: secondNode)
            }
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let firstNode = firstBody.node as? SKSpriteNode, secondNode = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
            }
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Projectile != 0) && (secondBody.categoryBitMask & PhysicsCategory.Walls != 0)) {
            if let firstNode = firstBody.node as? SKSpriteNode, secondNode = secondBody.node as? SKShapeNode {
                projectileDidCollideWithWall(firstBody.node as! SKSpriteNode, wall: secondBody.node as! SKShapeNode)
            }
        }
    }
    
    func shoot() {
//        // Choose one of the touches to work with
//        guard let touch = touches.first else {
//            return
//        }
//        let touchLocation = touch.locationInNode(self)
//        
        // Play sound effect on touch
        runAction(SKAction.playSoundFileNamed("M1 Garand.mp3", waitForCompletion: false))
        
        // Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        var playerpos = player.position
        if pressedButtons2.indexOf(buttonDirLeft2) != nil {
            playerpos.x = playerpos.x - (0.5 * player.size.width)
            projectile.position = playerpos
        }
        if pressedButtons2.indexOf(buttonDirRight2) != nil {
            playerpos.x = playerpos.x + (0.5 * player.size.width)
            projectile.position = playerpos
        }
        if pressedButtons2.indexOf(buttonDirUp2) != nil {
            playerpos.y = playerpos.y + (0.5 * player.size.height)
            projectile.position = playerpos
        }
        if pressedButtons2.indexOf(buttonDirDown2) != nil {
            playerpos.y = playerpos.y - (0.5 * player.size.height)
            projectile.position = playerpos
        }
        else if (pressedButtons2.indexOf(buttonDirUp2) != nil) && (pressedButtons2.indexOf(buttonDirRight2) != nil) {
            playerpos.y = playerpos.y + (0.5 * player.size.height)
            playerpos.x = playerpos.x - (0.5 * player.size.width)
            projectile.position = playerpos
        }
        else if (pressedButtons2.indexOf(buttonDirUp2) != nil) && (pressedButtons2.indexOf(buttonDirLeft2) != nil) {
            playerpos.y = playerpos.y + (0.5 * player.size.height)
            playerpos.x = playerpos.x - (0.5 * player.size.width)
            projectile.position = playerpos
        }
        else if (pressedButtons2.indexOf(buttonDirDown2) != nil) && (pressedButtons2.indexOf(buttonDirRight2) != nil) {
            playerpos.x = playerpos.x + (0.5 * player.size.width)
            playerpos.y = playerpos.y - (0.5 * player.size.height)
            projectile.position = playerpos
        }
        else if (pressedButtons2.indexOf(buttonDirDown2) != nil) && (pressedButtons2.indexOf(buttonDirLeft2) != nil) {
            playerpos.y = playerpos.y - (0.5 * player.size.height)
            playerpos.x = playerpos.x - (0.5 * player.size.width)
            projectile.position = playerpos
        }
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        // Important to set for fast moving bodies (like projectiles), because otherwise there is a chance that two fast moving bodies can pass through each other without a collision being detected
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        var speed: CGFloat = 3.0
        
        if pressedButtons2.count > 0 {
            addChild(projectile)
        }
        
        if pressedButtons2.count == 2 {
            speed = speed / sqrt(2.0)
            if (pressedButtons2.indexOf(buttonDirUp2) != nil) && (pressedButtons2.indexOf(buttonDirRight2) != nil) {
                projectile.physicsBody?.applyImpulse(CGVector(dx:speed, dy:speed))
            }
            if (pressedButtons2.indexOf(buttonDirUp2) != nil) && (pressedButtons2.indexOf(buttonDirLeft2) != nil) {
                projectile.physicsBody?.applyImpulse(CGVector(dx:-speed, dy:speed))
            }
            if (pressedButtons2.indexOf(buttonDirDown2) != nil) && (pressedButtons2.indexOf(buttonDirRight2) != nil) {
                projectile.physicsBody?.applyImpulse(CGVector(dx:speed, dy:-speed))
            }
            if (pressedButtons2.indexOf(buttonDirDown2) != nil) && (pressedButtons2.indexOf(buttonDirLeft2) != nil) {
                projectile.physicsBody?.applyImpulse(CGVector(dx:-speed, dy:-speed))
            }
        }
        
        if pressedButtons2.indexOf(buttonDirUp2) != nil {
            projectile.physicsBody?.applyImpulse(CGVector(dx:0, dy:speed))
        }
        if pressedButtons2.indexOf(buttonDirDown2) != nil {
            projectile.physicsBody?.applyImpulse(CGVector(dx:0, dy:-speed))
        }
        if pressedButtons2.indexOf(buttonDirLeft2) != nil {
            projectile.physicsBody?.applyImpulse(CGVector(dx:-speed, dy:0))
        }
        if pressedButtons2.indexOf(buttonDirRight2) != nil {
            projectile.physicsBody?.applyImpulse(CGVector(dx:speed, dy:0))
        }
//
//        // Determine offset of location to projectile
//        let offset = touchLocation - projectile.position
//        
//        addChild(projectile)
//
//        // Get the direction of where to shoot
//        let direction = offset.normalized()
//        
//        // Make it shoot far enough to be guaranteed off screen
//        let shootAmount = direction * 1000
//        
//        // Add the shoot amount to the current position
//        let realDest = shootAmount + projectile.position
//        
//        // Create the actions
//        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
//        let actionMoveDone = SKAction.removeFromParent()
//        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        print("Shooting")
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var speed: CGFloat = 3.0
        
        if pressedButtons1.count == 2 {
            speed = speed / sqrt(2.0)
        }

        if pressedButtons1.indexOf(buttonDirUp1) != nil {
            player.position.y += speed
        }
        if pressedButtons1.indexOf(buttonDirDown1) != nil {
            player.position.y -= speed
        }
        if pressedButtons1.indexOf(buttonDirLeft1) != nil {
            player.position.x -= speed
        }
        if pressedButtons1.indexOf(buttonDirRight1) != nil {
            player.position.x += speed
        }
    }
}