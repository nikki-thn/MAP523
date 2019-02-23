//
//  GameScene.swift
//  Midterm_MAP523
//
//  Created by Nikki on 2/20/19.
//  Copyright © 2019 Nikki. All rights reserved.
//

/*

Name: Nikki Truong
Student ID: 112 314 174
MAP523

*******/
import SpriteKit
import GameplayKit

class GameScene:  SKScene, SKPhysicsContactDelegate  {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var player1HealthLabel: SKLabelNode?
    var player2HealthLabel: SKLabelNode?
    var gameOverLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    
    var gameOver = false
    var gameStarted = false
    var activePlayer: Int = 1
    var player1Health: Int = 50
    var player2Health: Int = 50
    var hitCount1: Int = 0
    var hitCount2: Int = 0
    var winner: Int = 0
    
    var player1: SKSpriteNode?
    var player2: SKSpriteNode?
    var floor : SKSpriteNode?
    
    
    let player1Category: UInt32 = 0x1 << 1
    let player2Category: UInt32 = 0x1 << 2
    let bulletCategory: UInt32 = 0x1 << 3
    let brickCategory: UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        border.mass = 100000
        
        self.physicsWorld.contactDelegate = self
        
        createFloor()
        setGame()
    }
    
    func sprawnPlayer() {
        
        let maxX = size.width / 2
        let minX = -size.width / 2
        let range = maxX - minX
        let distance: CGFloat = 100 //distance between 2 objects
        
        let player1X = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        let player2X = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        
        player1?.position = CGPoint(x: player1X, y: 1000)
        player1?.physicsBody?.applyForce(CGVector(dx:0, dy: 5000))
        
        player2?.position = CGPoint(x: player2X + distance, y: 1000)
        player2?.physicsBody?.applyForce(CGVector(dx:0, dy: 5000))
    }
    
    func setGame() {
        
        floor = childNode(withName: "floor") as? SKSpriteNode
        player1 = childNode(withName: "player1") as? SKSpriteNode
        player2 = childNode(withName: "player2") as? SKSpriteNode
        
        player1?.physicsBody?.categoryBitMask = player1Category
        player1?.physicsBody?.contactTestBitMask = bulletCategory
        
        player2?.physicsBody?.categoryBitMask = player2Category
        player2?.physicsBody?.contactTestBitMask = bulletCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        player1HealthLabel = childNode(withName: "player1HealthLabel") as? SKLabelNode
        player2HealthLabel = childNode(withName: "player2HealthLabel") as? SKLabelNode
        gameOverLabel = childNode(withName: "gameOverLabel") as? SKLabelNode
        
        //scoreLabel?.fontSize = 50
        //scoreLabel?.text = "Score: \(score)"
        
        gameOverLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        gameOverLabel?.text = ""
        gameOverLabel?.isHidden = true
        gameStarted = true
        
        player1HealthLabel?.text = "Player 1 HP: \(player1Health)"
        player2HealthLabel?.text = "Player 2 HP: \(player2Health)"
    }
    
    func createFloor() {

        let tmp_element = SKSpriteNode()
        tmp_element.size = CGSize(width: 40, height: 25)
        let randomNumberForColumn = Int(size.width / tmp_element.size.width) + 1

        for column in 0...randomNumberForColumn {
            let randomNumberForRow = Int.random(in: 5 ... 10)
            for row in 0...randomNumberForRow {
            
                let element = SKSpriteNode(imageNamed: "blue.png")
                element.size = CGSize(width: 40, height: 25)
                element.name = "brick"
                element.physicsBody = SKPhysicsBody(rectangleOf: element.size)
                element.physicsBody?.categoryBitMask = brickCategory
                element.physicsBody?.contactTestBitMask = bulletCategory
                element.physicsBody?.affectedByGravity = false
                element.physicsBody?.isDynamic = false
                element.physicsBody?.allowsRotation = false
                element.physicsBody?.mass = 10000000
                addChild(element)

                let elementX = -size.width / 2 + element.size.width * CGFloat(column)
                let elementY = -(size.height / 2 - (element.size.height * CGFloat(row)))
                element.position = CGPoint(x: elementX , y: elementY)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if gameStarted == false {
            sprawnPlayer()
            gameStarted = true
        }
        
        if activePlayer == 1 {
            createBulletForPlayer1()
            activePlayer = 2
        } else if activePlayer == 2  {
            createBulletForPlayer2()
            activePlayer = 1
        }
    }
    
    func createBulletForPlayer1() {
        let projectile = SKSpriteNode(imageNamed: "green")
        projectile.zPosition = 1
        projectile.position = CGPoint(x: player1!.position.x, y: player1!.position.y + CGFloat(arc4random_uniform(UInt32(Int.random(in: 100 ... 300)))))
        projectile.size = CGSize(width: 20, height: 20)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.mass = 100
        projectile.physicsBody?.categoryBitMask = bulletCategory
        projectile.physicsBody?.contactTestBitMask = player2Category
        projectile.physicsBody?.contactTestBitMask = brickCategory
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(projectile)

        let action = SKAction.moveTo(x: self.frame.width, duration: 1)
        projectile.run(action)
    }
    
    func createBulletForPlayer2() {
        let projectile = SKSpriteNode(imageNamed: "yellow")
        projectile.zPosition = 1
        projectile.position = CGPoint(x: player2!.position.x, y: player2!.position.y + CGFloat(arc4random_uniform(UInt32(Int.random(in: 100 ... 300)))))
        projectile.size = CGSize(width: 20, height: 20)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.mass = 100
        projectile.physicsBody?.categoryBitMask = bulletCategory
        projectile.physicsBody?.contactTestBitMask = player1Category
        projectile.physicsBody?.contactTestBitMask = brickCategory
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(projectile)
        let action = SKAction.moveTo(x: -self.frame.width, duration: 1)
        projectile.run(action)
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == player1Category && secondBody.categoryBitMask == bulletCategory {
            secondBody.node?.removeFromParent()
            player1Health = player1Health - Int(Double(player1Health) * 0.2) - 1 //damage
            player1HealthLabel?.text = "Player 1 HP: \(player1Health)"
            hitCount2 += 1
            print("Player 1 has been hit")
        } else if firstBody.categoryBitMask == player2Category && secondBody.categoryBitMask == bulletCategory {
            secondBody.node?.removeFromParent()
            player2Health = player2Health - Int(Double(player2Health) * 0.2) - 1
            player2HealthLabel?.text = "Player 2 HP: \(player2Health)"
            hitCount1 += 1
            print("Player 2 has been hit")
        } else if firstBody.categoryBitMask == bulletCategory && secondBody.categoryBitMask == brickCategory {
            secondBody.node?.removeFromParent()
            firstBody.node?.removeFromParent()
            print("Bullet hit the brick")
        }
        
        if player1Health <= 0 {
            gameIsOver()
            winner = 2
        } else if player2Health <= 0 {
            gameIsOver()
            winner = 1
        }
    }
    
    func gameIsOver() {
        gameOver = true
        player1Health = 0
        player2Health = 0
        //gameEndedEffect()
        //sleep(5)
        gameOverLabel?.isHidden = false
        gameOverLabel?.fontSize = 50
        gameOverLabel?.position = CGPoint(x: 0, y: 100)
        gameOverLabel?.text = "Battle ended"
        scoreLabel?.text = "Player \(winner) won!"
        //clearNodes()
    }
}
