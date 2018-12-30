//
//  GameScene.swift
//  GingerBreadGame
//
//  Created by Miguel Barba on 12/25/18.
//  Copyright © 2018 MBH. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gingerBreadMan : SKSpriteNode?
    var breadTimer : Timer?
    var birdTimer : Timer?
    var ceil : SKSpriteNode?
    var scoreLabel : SKLabelNode?
    var yourScoreLabel : SKLabelNode?
    var finalScoreLabel : SKLabelNode?
    
    let gingerBreadManCategory : UInt32 = 0x1 << 1
    let breadCategory : UInt32 = 0x1 << 2
    let birdCategory : UInt32 = 0x1 << 3
    let groundAndCeilCategory : UInt32 = 0x1 << 4
    
    var score = 0
    
    override func didMove(to view: SKView){
        
        physicsWorld.contactDelegate = self
        
        gingerBreadMan = childNode(withName: "gingerBreadMan") as? SKSpriteNode
        gingerBreadMan?.physicsBody?.categoryBitMask = gingerBreadManCategory
        gingerBreadMan?.physicsBody?.contactTestBitMask = breadCategory | birdCategory
        gingerBreadMan?.physicsBody?.collisionBitMask = groundAndCeilCategory
        
        var gingerBreadManRun : [SKTexture] = []
        for number in 0...1{
            print("Number: \(number)")
            gingerBreadManRun.append(SKTexture(imageNamed: "gingerBreadMan\(number)"))
        }
        gingerBreadMan?.run(SKAction.repeatForever(SKAction.animate(with: gingerBreadManRun, timePerFrame: 0.09)))
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = gingerBreadManCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        startTimers()
        createGround()
        //breadTime = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.createBread()})
    }
    
    func createGround() {
        let sizingGround = SKSpriteNode(imageNamed:"candy")
        let numberOfGround = Int(size.width / sizingGround.size.width) + 1
        for number in 0...numberOfGround {
            let ground = SKSpriteNode(imageNamed: "candy")
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = groundAndCeilCategory
            ground.physicsBody?.collisionBitMask = gingerBreadManCategory
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            addChild(ground)
            
            let groundX = -size.width / 2 + ground.size.width / 2 + ground.size.width * CGFloat(number)
            ground.position = CGPoint(x: groundX, y: -size.height / 2 + ground.size.height / 2 - 18)
            let speed = 100.0
            let firstMoveLeft = SKAction.moveBy(x: -ground.size.width - ground.size.width * CGFloat(number), y: 0, duration: TimeInterval(ground.size.width + ground.size.width * CGFloat(number)) / speed)
            let resetGround = SKAction.moveBy(x: size.width + ground.size.width, y: 0, duration: 0)
            let groundFullMove = SKAction.moveBy(x: -size.width - ground.size.width, y: 0, duration: TimeInterval(size.width + ground.size.width) / speed)
            let groundMovingForever = SKAction.repeatForever(SKAction.sequence([groundFullMove,resetGround]))
            
            ground.run(SKAction.sequence([firstMoveLeft,resetGround,groundMovingForever]))
        }
    }
    
    func startTimers(){
        breadTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats : true, block: { (timer) in self.createBread() })
        birdTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in self.createBird()})
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if scene?.isPaused == false {
            gingerBreadMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 1_000))
        }
        let touch = touches.first
        if let location = touch?.location(in: self){
            let theNodes = nodes(at: location)
            for node in theNodes {
                if node.name == "play" {
                    //Restarts Game
                    score = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimers()
                }
            }
        }
    }
    
    func createBread() {
        let bread = SKSpriteNode(imageNamed: "bread")
        bread.size = gingerBreadMan?.size ?? CGSize(width: size.width / 7, height: size.height / 11)
        bread.physicsBody = SKPhysicsBody(rectangleOf: bread.size)
        bread.physicsBody?.affectedByGravity = false
        bread.physicsBody?.categoryBitMask = breadCategory
        bread.physicsBody?.contactTestBitMask = gingerBreadManCategory
        bread.physicsBody?.collisionBitMask = 0
        addChild(bread)
        
        let sizingGround = SKSpriteNode(imageNamed: "candy")
        
        let maxY = size.height / 2 - bread.size.height / 2
        let minY = -size.height / 2 + bread.size.height / 2 + sizingGround.size.height
        let range = maxY - minY
        let breadY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bread.position = CGPoint(x: size.width / 2 + bread.size.width / 2, y: breadY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bread.size.width, y: 0, duration: 4)
        
        bread.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    func createBird() {
        let bird = SKSpriteNode(imageNamed: "seagull")
        bird.size = gingerBreadMan?.size ?? CGSize(width: size.width / 7, height: size.height / 11)
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = gingerBreadManCategory
        bird.physicsBody?.collisionBitMask = 0
        addChild(bird)
        
        let sizingGround = SKSpriteNode(imageNamed:"candy")
        
        let maxY = size.height / 2 - bird.size.height / 2
        let minY = -size.height / 2 + bird.size.height / 2 + sizingGround.size.height
        let range = maxY - minY
        let birdY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bird.position = CGPoint(x: size.width / 2 + bird.size.width / 2, y: birdY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bird.size.width, y: 0, duration: 4)
        
        bird.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        if contact.bodyA.categoryBitMask == breadCategory {
            contact.bodyA.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        if contact.bodyB.categoryBitMask == breadCategory {
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        
        if contact.bodyA.categoryBitMask == birdCategory {
            contact.bodyA.node?.removeFromParent()
            gameOver()
        }
        if contact.bodyB.categoryBitMask == birdCategory {
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
    }
    
    func gameOver(){
        scene?.isPaused = true
        
        breadTimer?.invalidate()
        birdTimer?.invalidate()
        
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if yourScoreLabel != nil {
            addChild(finalScoreLabel!)
        }
        
        let playButton =  SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
    }
    
}
