//
//  GameScene.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-02-19.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var scoreLabel: SKLabelNode?
    var gameOverLabel: SKLabelNode?
   
    var ball : SKSpriteNode?
    var floor : SKSpriteNode?
    var paddle : SKSpriteNode?
    
    var score = 0
    var blue = 10
    var yellow = 15
    var green = 5
    var gameHasEnded = false
    var gameStarted = false
    var moveFactor: CGFloat = 1000000000
    
    let ballCategory: UInt32 = 0x1 << 1
    let paddleCategory: UInt32 = 0x1 << 2
    let yellowBrickCategory: UInt32 = 0x1 << 3
    let greenBrickCategory: UInt32 = 0x1 << 4
    let blueBrickCategory: UInt32 = 0x1 << 5
    let bottomCategory: UInt32 = 0x1 << 6
    
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        border.mass = 100000
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
    }
    
    func startGame() {
        floor = childNode(withName: "bottom") as? SKSpriteNode
        ball = childNode(withName: "ball") as? SKSpriteNode
        paddle = childNode(withName: "paddle") as? SKSpriteNode
        ball?.physicsBody!.applyImpulse(CGVector(dx: 50, dy: -50))
        paddle?.physicsBody!.mass = 100000
        ball?.physicsBody!.categoryBitMask = ballCategory
        ball?.physicsBody!.contactTestBitMask = bottomCategory
        ball?.physicsBody!.contactTestBitMask = greenBrickCategory
        ball?.physicsBody!.contactTestBitMask = blueBrickCategory
        ball?.physicsBody!.contactTestBitMask = yellowBrickCategory
        
        floor?.physicsBody?.categoryBitMask = bottomCategory
        floor?.physicsBody?.contactTestBitMask = ballCategory
        
        createBrick(color: "yellow", adjustYPosition: 100, numRows: 3, category: yellowBrickCategory)
        createBrick(color: "blue", adjustYPosition: 200, numRows: 2, category: blueBrickCategory)
        createBrick(color: "green", adjustYPosition: 300, numRows: 5, category: greenBrickCategory)
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.fontSize = 50
        scoreLabel?.text = "Score: \(score)"
        
        gameOverLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        gameOverLabel?.text = ""
        gameOverLabel?.isHidden = true
    }
    
    func createBrick(color: String, adjustYPosition: CGFloat, numRows: Int, category: UInt32) {
        
        let tmp_element = SKSpriteNode(imageNamed: "\(color).png")
        tmp_element.size = CGSize(width: 50, height: 20)
        let numberOfElements = Int(size.width / tmp_element.size.width) + 1

        for row in 0...numRows {
            for column in 0...numberOfElements {
                
                let element = SKSpriteNode(imageNamed: "\(color).png")
                element.size = CGSize(width: 50, height: 20)
                element.name = "brick"
                element.physicsBody = SKPhysicsBody(rectangleOf: element.size)
                element.physicsBody?.categoryBitMask = category
                element.physicsBody?.contactTestBitMask = ballCategory
                element.physicsBody?.affectedByGravity = false
                element.physicsBody?.isDynamic = false
                element.physicsBody?.allowsRotation = false
                element.physicsBody?.mass = 10000000
                addChild(element)

                let elementX = -size.width / 2 + element.size.width * CGFloat(column)
                let elementY = size.height / 2 - adjustYPosition - (element.size.height * CGFloat(row))
                element.position = CGPoint(x: elementX , y: elementY)
            }
        }
    }
    
    func gameEndedEffect() {
        for child in self.children{
            if child.name == "brick"{
                child.physicsBody? = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
                child.physicsBody?.affectedByGravity = true
                //child.physicsBody?.mass = 10000000
               // child.physicsBody?.allowsRotation = true
                child.physicsBody?.angularDamping = 100
                child.physicsBody?.friction = -10000
                child.physicsBody?.angularVelocity = 500
                child.physicsBody?.linearDamping = 500
                child.physicsBody?.applyForce(CGVector(dx: 30000, dy: 30000))
            }
        }

    }
    
    func clearNodes() {
        for child in self.children{
            if child.name == "brick"{
                 child.removeFromParent()
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            paddle?.position.x = touchLocation.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            gameStarted = true
            startGame()
        }
        
        for touch in touches {
            let touchLocation = touch.location(in: self)
            paddle?.position.x = touchLocation.x
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        // 2.
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // 3.
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == yellowBrickCategory {
            secondBody.node?.removeFromParent()
            score += yellow
            scoreLabel?.text = "Score: \(score)"
            print("Yellow contact has been made.")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blueBrickCategory {
            secondBody.node?.removeFromParent()
            score += blue
            scoreLabel?.text = "Score: \(score)"
            print("Blue contact has been made.")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == greenBrickCategory {
            secondBody.node?.removeFromParent()
            score += green
            scoreLabel?.text = "Score: \(score)"
            print("Green contact has been made.")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            firstBody.node?.removeFromParent()
            print("Bottom contact has been made.")
            gameOver()
            gameHasEnded = true
        }
        
        if gameHasEnded == false {
            speedUp() //speed up the game after every touch
        }
    }
    
    //func speedUp(speed: CGFloat) {
    func speedUp() {
//        print("call")
//        moveFactor *= 50000000000
//        ball?.position = CGPoint(x: (0 + moveFactor * CGFloat(score)), y: (0 + moveFactor * CGFloat(score)))
         ball?.physicsBody!.angularDamping += 0.001
        ball?.physicsBody!.restitution += 0.0005
    }
    
    func gameOver() {
        gameEndedEffect()
        //sleep(5)
        gameOverLabel?.isHidden = false
        gameOverLabel?.fontSize = 150
        gameOverLabel?.position = CGPoint(x: 0, y: 100)
        gameOverLabel?.text = "Game over"
        //clearNodes()
    }
    
}
