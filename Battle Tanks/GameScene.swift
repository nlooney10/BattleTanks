//
//  GameScene.swift
//  Battle Tanks
//
//  Created by Nicholas Looney on 11/9/15.
//  Copyright (c) 2015 Nicholas Looney. All rights reserved.
//

import Foundation
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
let Pi = CGFloat(M_PI)
let DegreesToRadians = Pi / 180

class GameScene: SKScene, SKPhysicsContactDelegate {
	
    var player = SKSpriteNode(imageNamed: "player")
    var monster = SKSpriteNode(imageNamed: "monster")
    var monstersDestroyed = 0
    var shooting = false
    var lastShootingTime: CFTimeInterval = 0
    var delayBetweenShots: CFTimeInterval = 0.5
    var shooter: NSTimer?
    var monsterShooter: NSTimer?
	var joystick:Joystick?
	var joystick2:Joystick?
    
    override init(size: CGSize) {
		
        super.init(size: size)
        scaleMode = SKSceneScaleMode.AspectFill
    }

    required init?(coder aDecoder: NSCoder) {
		
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
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
        self.addChild(player)
        
//        runAction(SKAction.repeatActionForever(
//            SKAction.sequence([
//                SKAction.runBlock(addMonster),
//                SKAction.waitForDuration(3.0)
//                ])
//            ))
        
        let monster = Enemy(pos: CGPoint(x: size.width * 0.7, y: size.height * 0.7))
        monster.position = CGPoint(x: size.width * 0.7, y: size.height * 0.7)
        addChild(monster)
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
        
//        let rectangle = Walls(pos: CGPointMake(frame.midX-10, frame.midY + 50))
//        self.addChild(rectangle)
        
        let line = SKShapeNode(rectOfSize: CGSize(width: 0, height: 40))
        line.position = CGPointMake(frame.midX-10, frame.midY + 80)
        line.strokeColor = SKColor.blackColor()
        line.glowWidth = 1.0
        
        line.physicsBody = SKPhysicsBody(edgeChainFromPath: line.path!)
        line.physicsBody?.dynamic = false
        line.physicsBody?.categoryBitMask = PhysicsCategory.Walls
        line.physicsBody?.contactTestBitMask = PhysicsCategory.None
        line.physicsBody?.collisionBitMask = PhysicsCategory.All
        self.addChild(line)
        
//        self.monsterShooter = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "enemyShoot", userInfo: nil, repeats: true)
//		
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
		
		let joystick = Joystick(position: CGPoint(x: 60, y: 50))
		self.addChild(joystick)
		self.joystick = joystick
		
		let joystick2 = Joystick(position: CGPoint(x: 250, y: 50))
		self.addChild(joystick2)
		joystick2.buttonPressed = {

			self.shoot()
		}
		self.joystick2 = joystick2
    }
    
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

		if let joystick = self.joystick {
		
			joystick.touchesBegan(touches, withEvent: event)
		}
		if let joystick = self.joystick2 {
			
			joystick.touchesBegan(touches, withEvent: event)
		}
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		
		if let joystick = self.joystick {
			
			joystick.touchesMoved(touches, withEvent: event)
		}
		if let joystick = self.joystick2 {
			
			joystick.touchesMoved(touches, withEvent: event)
		}
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //func addMonster() {
        
        // Create sprite
        //let monster = Enemy(pos: CGPoint(x: size.width * 0.7, y: size.height * 0.7))
        //addChild(monster)
        
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
        
    //}
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		
		if let joystick = self.joystick {
			
			joystick.touchesEnded(touches, withEvent: event)
		}
		if let joystick = self.joystick2 {
			
			joystick.touchesEnded(touches, withEvent: event)
		}
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		
		print("=== touch cancelled")
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
		
		guard self.joystick2 != nil
			else {
				
				return
		}
		print("=== shoot")
        // Play sound effect on touch
		runAction(SKAction.playSoundFileNamed("M1 Garand.mp3", waitForCompletion: false))
		SKAction.changeVolumeTo(0.1, duration: 0)
	
		// Set up initial location of projectile
		let projectile = SKSpriteNode(imageNamed: "projectile")
		var playerpos = player.position
		if joystick2!.pressedButtons.count == 1 {
			
			if joystick2!.buttonLeft.pressed {
				
				playerpos.x = playerpos.x - (0.9 * player.size.width)
				projectile.position = playerpos
			} else if joystick2!.buttonRight.pressed {
				
				playerpos.x = playerpos.x + (0.9 * player.size.width)
				projectile.position = playerpos
			} else if joystick2!.buttonUp.pressed {
				
				playerpos.y = playerpos.y + (0.8 * player.size.height)
				projectile.position = playerpos
			} else if joystick2!.buttonDown.pressed {
				
				playerpos.y = playerpos.y - (0.8 * player.size.height)
				projectile.position = playerpos
			}
		} else if joystick2!.pressedButtons.count == 2 {
			
			if joystick2!.buttonUp.pressed && joystick2!.buttonRight.pressed {
				
				playerpos.y = playerpos.y + (0.8 * player.size.height)
				playerpos.x = playerpos.x + (0.8 * player.size.width)
				projectile.position = playerpos
			} else if joystick2!.buttonUp.pressed && joystick2!.buttonLeft.pressed {
				
				playerpos.y = playerpos.y + (0.8 * player.size.height)
				playerpos.x = playerpos.x - (0.8 * player.size.width)
				projectile.position = playerpos
			} else if joystick2!.buttonDown.pressed && joystick2!.buttonRight.pressed {
				
				playerpos.x = playerpos.x + (0.8 * player.size.width)
				playerpos.y = playerpos.y - (0.8 * player.size.height)
				projectile.position = playerpos
			} else if joystick2!.buttonDown.pressed && joystick2!.buttonLeft.pressed {
				
				playerpos.y = playerpos.y - (0.8 * player.size.height)
				playerpos.x = playerpos.x - (0.8 * player.size.width)
				projectile.position = playerpos
			}
		}
            
		projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
		projectile.physicsBody?.dynamic = true
		projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
		projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
		projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
		// Important to set for fast moving bodies (like projectiles), because otherwise there is a chance that two fast moving bodies can pass through each other without a collision being detected
		projectile.physicsBody?.usesPreciseCollisionDetection = true
		
		var speed: CGFloat = 3.0
		
		if joystick2!.pressedButtons.count > 0 {
			
			addChild(projectile)
		}
		
		if joystick2!.pressedButtons.count == 2 {
			
			speed = speed / sqrt(2.0)
			
			if joystick2!.buttonUp.pressed &&
				joystick2!.buttonRight.pressed &&
				!joystick2!.buttonDown.pressed &&
				!joystick2!.buttonLeft.pressed {
					
				projectile.physicsBody?.applyImpulse(CGVector(dx:speed, dy:speed))
			}
			else if joystick2!.buttonUp.pressed &&
				joystick2!.buttonLeft.pressed &&
				!joystick2!.buttonDown.pressed &&
				!joystick2!.buttonRight.pressed {
			
				projectile.physicsBody?.applyImpulse(CGVector(dx:-speed, dy:speed))
			}
			else if joystick2!.buttonDown.pressed &&
				joystick2!.buttonRight.pressed &&
				!joystick2!.buttonUp.pressed &&
				!joystick2!.buttonLeft.pressed {
					
				projectile.physicsBody?.applyImpulse(CGVector(dx:speed, dy:-speed))
			}
			else if joystick2!.buttonDown.pressed &&
				joystick2!.buttonLeft.pressed &&
				!joystick2!.buttonUp.pressed &&
				!joystick2!.buttonRight.pressed {
					
				projectile.physicsBody?.applyImpulse(CGVector(dx:-speed, dy:-speed))
			}
		} else if joystick2!.buttonUp.pressed {
			
			projectile.physicsBody?.applyImpulse(CGVector(dx:0, dy:speed))
		}
		else if joystick2!.buttonDown.pressed {
			
			projectile.physicsBody?.applyImpulse(CGVector(dx:0, dy:-speed))
		}
		else if joystick2!.buttonLeft.pressed {
			
			projectile.physicsBody?.applyImpulse(CGVector(dx:-speed, dy:0))
		}
		else if joystick2!.buttonRight.pressed {
			
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
    }
    
    func enemyShoot() {
        runAction(SKAction.playSoundFileNamed("M1 Garand.mp3", waitForCompletion: false))
        let monProjectile = SKSpriteNode(imageNamed: "projectile")
        var monpon = CGPoint(x: size.width * 0.7, y: size.height * 0.7)
        monpon.x = monpon.x - monster.size.width * 0.9
        //monpon.y = monpon.y + monster.size.height * 0.9
        monProjectile.position = monpon
        monProjectile.physicsBody = SKPhysicsBody(circleOfRadius: monProjectile.size.width/2)
        monProjectile.physicsBody?.dynamic = true
        monProjectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        monProjectile.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        monProjectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        monProjectile.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(monProjectile)
        
        let deltaX = player.position.x - monProjectile.position.x
        let deltaY = player.position.y - monProjectile.position.y
        let angle = atan2(deltaX, deltaY)
        //monProjectile.position = monster.position
        print(monProjectile.position)
        //print(monster.position)
        //monProjectile.zRotation = angle - 90 * DegreesToRadians
        //let missileMoveAction = SKAction.moveTo(monster.position, duration: 2)
        //monProjectile.runAction(missileMoveAction) {
            monProjectile.physicsBody?.applyAngularImpulse(angle)
        print(angle)
        //}
        print("monster shooting")
    }
   
    override func update(currentTime: CFTimeInterval) {
		
        /* Called before each frame is rendered */
        var speed: CGFloat = 3.0
		
		if let joystick = joystick {
			
			if joystick.pressedButtons.count == 2 {
				
				speed = speed / sqrt(2.0)
			}

			if joystick.buttonUp.pressed {
				
				player.position.y += speed
			}
			if joystick.buttonDown.pressed {
				
				player.position.y -= speed
			}
			if joystick.buttonLeft.pressed {
				
				player.position.x -= speed
			}
			if joystick.buttonRight.pressed {
				
				player.position.x += speed
			}
		}
    }
}