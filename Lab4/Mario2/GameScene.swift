//
//  GameScene.swift
//  Mario2
//
//  Created by Alireza Moghaddam on 2019-02-02.
//  Copyright © 2019 Alireza. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    var scoreLabel: SKLabelNode?
    var lifeLabel: SKLabelNode?
    
    var mario: SKSpriteNode?  //SKSpriteNode is an onscreen graphical element that can be initialized from an image or a solid color. SpriteKit adds functionality to its ability to display images. For more information:
    //https://developer.apple.com/documentation/spritekit/skspritenode
    
    
    var coinTimer: Timer?
    var cloudTimer: Timer?
   
    var score = 0
    var life = 1
    
    let marioCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    //let cloudCategory: UInt32 = 0x1 << 4
    
    
    override func didMove(to view: SKView) {
        
        
        physicsWorld.contactDelegate = self  //The driver of the physics engine in a scene; it exposes the ability for you to configure and query the physics system.
       
        mario = childNode(withName: "mario") as? SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        lifeLabel = childNode(withName: "healthLabel") as? SKLabelNode
        
        
        mario?.physicsBody?.categoryBitMask = marioCategory
        mario?.physicsBody?.contactTestBitMask = coinCategory
        mario?.physicsBody?.contactTestBitMask = bombCategory
        //mario?.physicsBody?.collisionBitMask = cloudCategory;

        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in self.createCoin()})
        
        cloudTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createCloud()})
        
        cloudTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {(timer) in self.createBomb()})
    
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        mario?.physicsBody?.applyForce(CGVector(dx:0, dy: 50000))

    }
    
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 100, height: 100)
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = marioCategory
        
        //coin.physicsBody?.collisionBitMask = 0
        
        addChild(coin)
        
        let maxY = size.height / 2 - coin.size.height / 2
        let minY = -size.height / 2 + coin.size.height / 2
        let range = maxY - minY
        
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        coin.position = CGPoint(x: size.width / 2 + coin.size.width / 2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - coin.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        coin.run(mySeq)
    }
    
    func createBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.size = CGSize(width: 100, height: 100)
        bomb.physicsBody = SKPhysicsBody(rectangleOf:  bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = marioCategory
        
        //coin.physicsBody?.collisionBitMask = 0
        
        addChild(bomb)
        
        let maxY = size.height / 2 - bomb.size.height / 2
        let minY = -size.height / 2 + bomb.size.height / 2
        let range = maxY - minY
        
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position = CGPoint(x: size.width / 2 + bomb.size.width / 2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        bomb.run(mySeq)
    }
    
    func createCloud() {
        let cloud = SKSpriteNode(imageNamed: "cloud")
        cloud.size = CGSize(width: 200, height: 200)
        //cloud.physicsBody = SKPhysicsBody(rectangleOf: cloud.size)
        //cloud.physicsBody?.affectedByGravity = false
        
        //cloud.physicsBody?.categoryBitMask = cloudCategory
       // cloud.physicsBody?.collisionBitMask = -1
        //cloud.physicsBody?.collisionBitMask = 0
        
        addChild(cloud)
        
        let maxY = size.height / 2 - cloud.size.height / 2
        let minY = -size.height / 2 + cloud.size.height / 2
        let range = maxY - minY
        
        let cloudY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        cloud.position = CGPoint(x: size.width / 2 + cloud.size.width / 2, y: cloudY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - cloud.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        cloud.run(mySeq)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        updateScore()

        if life != 0 {
            if contact.bodyB.categoryBitMask == coinCategory {
                contact.bodyB.node?.removeFromParent()
                score += 1
            } else if contact.bodyB.categoryBitMask == bombCategory {
                contact.bodyB.node?.removeFromParent()
                life -= 1
                updateScore()
            }
        }
        else {
            mario?.removeFromParent()
            scoreLabel?.text = "Score: \(score)"
            gameOver()
        }
    }
    
    func updateScore() {
        scoreLabel?.text = "Score: \(score)"
        lifeLabel?.text = "Health: \(life)"
    }
    
    func gameOver() {
        let restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.name = "restart"
        restartBtn.isUserInteractionEnabled = false
        addChild(restartBtn)
        restartBtn.position = CGPoint(x: 0, y: 0)
        
        lifeLabel?.text = "Game over"
        lifeLabel?.position = CGPoint(x: 0, y: 100)
        lifeLabel?.fontColor = UIColor.red
        scoreLabel?.position = CGPoint(x: 0, y: 200)
    }

}

