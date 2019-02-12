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
    
    
    var timer: Timer?
    var cloudTimer: Timer?
    var extraLiveTimer: Timer?
    
    var score = 0
    var life = 2
    
    let marioCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let extraLiveCategory: UInt32 = 0x1 << 4
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self  //The driver of the physics engine in a scene; it exposes the ability for you to configure and query the physics system.
        
        mario = childNode(withName: "mario") as? SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        lifeLabel = childNode(withName: "msgLabel") as? SKLabelNode
        
        
        mario?.physicsBody?.categoryBitMask = marioCategory
        mario?.physicsBody?.contactTestBitMask = coinCategory
        mario?.physicsBody?.contactTestBitMask = bombCategory
        mario?.physicsBody?.contactTestBitMask = extraLiveCategory;
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in self.createCoin()})
        
        cloudTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createCloud()})
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {(timer) in self.createBomb()})
        
        extraLiveTimer = Timer.scheduledTimer(withTimeInterval: 50, repeats: true, block: {(timer) in self.createExtraLive()})
        
        for number in 1...life {
            addLife(numOfLives: number)
        }
        
        scoreLabel?.text = "Score: \(score)"
        
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
        coin.physicsBody?.mass = 0
        
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
        bomb.physicsBody?.mass = 0

        
        addChild(bomb)
        
        let maxY = size.height / 2 - bomb.size.height / 5
        let minY = -size.height / 2 + bomb.size.height / 2
        let range = maxY - minY
        
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position = CGPoint(x: size.width / 2 + bomb.size.width / 2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        bomb.run(mySeq)
    }
    
    func createExtraLive() {
        if life < 5 {
            let live = SKSpriteNode(imageNamed: "superMario")
            live.size = CGSize(width: 100, height: 100)
            live.physicsBody = SKPhysicsBody(rectangleOf:  live.size)
            live.physicsBody?.affectedByGravity = false
            
            live.physicsBody?.categoryBitMask = extraLiveCategory
            live.physicsBody?.contactTestBitMask = marioCategory
            live.physicsBody?.mass = 0
            
            addChild(live)
            
            let maxY = size.height / 2 - live.size.height / 4
            let minY = -size.height / 2 + live.size.height / 2
            let range = maxY - minY
            
            let liveY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
            
            live.position = CGPoint(x: size.width / 2 + live.size.width / 2, y: liveY)
            
            let moveLeft = SKAction.moveBy(x: -size.width - live.size.width, y: 0, duration: 4)
            let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
            live.run(mySeq)
        }
    }
    
    func createCloud() {
        let cloud = SKSpriteNode(imageNamed: "cloud")
        cloud.size = CGSize(width: 200, height: 200)
        
        addChild(cloud)
        
        let maxY = size.height / 2 - cloud.size.height / 3
        let minY = -size.height / 2 + cloud.size.height / 2
        let range = maxY - minY
        
        let cloudY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        cloud.position = CGPoint(x: size.width / 2 + cloud.size.width / 2, y: cloudY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - cloud.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        cloud.run(mySeq)
    }
    
    func addLife(numOfLives: Int) {
        let life = SKSpriteNode(imageNamed: "superMario")
        life.size = CGSize(width: 75, height: 75)
        life.position = CGPoint(x: -300 + numOfLives * 60, y: Int(size.height / 2 - 85))
        print(numOfLives)
        life.name = "live\(numOfLives)"
        addChild(life)
    }
    
    func removeLife(numOfLives: Int) {
        for child in self.children{
            if child.name == "live\(numOfLives + 1)"{
                child.removeFromParent()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyB.categoryBitMask == coinCategory {
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        } else if contact.bodyB.categoryBitMask == bombCategory {
            contact.bodyB.node?.removeFromParent()
            life -= 1
            removeLife(numOfLives: life)
            if life == 0 {
                mario?.removeFromParent()
                scoreLabel?.text = "Score: \(score)"
                gameOver()
            }
        } else if contact.bodyB.categoryBitMask == extraLiveCategory {
            contact.bodyB.node?.removeFromParent()
            life += 1
            addLife(numOfLives: life)
        }
    }
    
    //    func updateScore() {
    //        scoreLabel?.text = "Score: \(score)"
    //        lifeLabel?.text = "Health: \(life)"
    //    }
    
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
        lifeLabel?.isHidden = false
        scoreLabel?.position = CGPoint(x: 0, y: 200)
    }
    
}

