//
//  GameScene.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-02-19.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation


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
    
    let ballCategory: UInt32 = 0x1 << 1
    let paddleCategory: UInt32 = 0x1 << 2
    let yellowBrickCategory: UInt32 = 0x1 << 3
    let greenBrickCategory: UInt32 = 0x1 << 4
    let blueBrickCategory: UInt32 = 0x1 << 5
    let bottomCategory: UInt32 = 0x1 << 6
    let borderCategory: UInt32 = 0x1 << 7
    
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
        //create border to trap the ball object
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        border.mass = 100000
        border.categoryBitMask = borderCategory
        border.contactTestBitMask = ballCategory
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0) //for gravity
        self.physicsWorld.contactDelegate = self

        
        //for start label
        gameOverLabel = childNode(withName: "gameOverLabel") as? SKLabelNode
        gameOverLabel?.isHidden = false
        gameOverLabel?.fontSize = 50
        gameOverLabel?.position = CGPoint(x: 0, y: 100)
        gameOverLabel?.text = "Touch the screen to start"
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.fontSize = 50
        scoreLabel?.position = CGPoint(x: -size.width / 2 + 200, y: size.height / 2 - 100)
        scoreLabel?.text = "Score: \(score)"
        
    }
    
    func startGame() {
        
        let quitBtn = SKSpriteNode(imageNamed: "close")
        quitBtn.size = CGSize(width:50, height:50)
        quitBtn.name = "quit"
       // quitBtn.isUserInteractionEnabled = true
        
        quitBtn.position = CGPoint(x: size.width / 2 - 100, y: size.height / 2 - 80)
        addChild(quitBtn)
        
        //declare the nodes
        floor = childNode(withName: "bottom") as? SKSpriteNode
        ball = childNode(withName: "ball") as? SKSpriteNode
        paddle = childNode(withName: "paddle") as? SKSpriteNode
       
        //apply impulse so the ball moves
        ball?.physicsBody!.applyImpulse(CGVector(dx: 50, dy: -50))
        paddle?.physicsBody!.mass = 100000 //
        
        //contact categories
        ball?.physicsBody!.categoryBitMask = ballCategory
        ball?.physicsBody!.contactTestBitMask = bottomCategory
        ball?.physicsBody!.contactTestBitMask = paddleCategory
        ball?.physicsBody!.contactTestBitMask = greenBrickCategory
        ball?.physicsBody!.contactTestBitMask = blueBrickCategory
        ball?.physicsBody!.contactTestBitMask = yellowBrickCategory
        ball?.physicsBody!.contactTestBitMask = borderCategory
        
        floor?.physicsBody?.categoryBitMask = bottomCategory
        floor?.physicsBody?.contactTestBitMask = ballCategory
        
        paddle?.physicsBody?.categoryBitMask = paddleCategory
        paddle?.physicsBody!.contactTestBitMask = ballCategory
        
        //call createBrick method
        createBrick(color: "yellow", adjustYPosition: 150, numRows: 3, category: yellowBrickCategory)
        createBrick(color: "blue", adjustYPosition: 250, numRows: 2, category: blueBrickCategory)
        createBrick(color: "green", adjustYPosition: 350, numRows: 5, category: greenBrickCategory)
        
        //hide gameOverLabel
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
    
    func stopGame() {
        paddle?.isUserInteractionEnabled = false
        audioPlayer.muteBackgroundSound()
        audioPlayer.backgroundSoundIsMuted = true
        print("called")
    }
    
    func gameEndedEffect() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.0)
        for child in self.children{
            if child.name == "brick"{
                child.physicsBody? = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
                child.physicsBody?.affectedByGravity = true
                child.physicsBody?.mass = 1000
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

        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            
            //Iterate through all elements on the scene to see if the click event has happened on the "Play/Resume" button
            for node in theNodes {
                if node.name == "quit" {
                   stopGame()
                }
            }
        }
        
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
            audioPlayer.playImpactSound(sound: "impact2")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blueBrickCategory {
            secondBody.node?.removeFromParent()
            score += blue
            scoreLabel?.text = "Score: \(score)"
            print("Blue contact has been made.")
            audioPlayer.playImpactSound(sound: "impact2")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == greenBrickCategory {
            secondBody.node?.removeFromParent()
            score += green
            scoreLabel?.text = "Score: \(score)"
            print("Green contact has been made.")
            audioPlayer.playImpactSound(sound: "impact2")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory {
            audioPlayer.playImpactSound(sound: "impact1")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == borderCategory {
            audioPlayer.playImpactSound(sound: "impact1")
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            firstBody.node?.removeFromParent()
            paddle?.removeFromParent()
            print("Bottom contact has been made.")
            gameOver()
            gameHasEnded = true
            audioPlayer.playImpactSound(sound: "gameOver")
        }
        
        if gameHasEnded == false {
            speedUp() //speed up the game after every touch
        }
    }
    
    func speedUp() {
        ball?.physicsBody!.angularDamping +=  0.001
        ball?.physicsBody!.restitution += 0.0005
    }
    
    func gameOver() {
        gameEndedEffect()
            
        scoreLabel?.position = CGPoint(x: 0, y: 200)
        gameOverLabel?.isHidden = false
        gameOverLabel?.fontSize = 100
        gameOverLabel?.position = CGPoint(x: 0, y: 100)
        gameOverLabel?.text = "Game over"
    }
    
}
