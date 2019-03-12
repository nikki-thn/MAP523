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

//Global variable for game current status ie to keep playing or stop game
struct gamePlay {
    static var gameHasEnded = false
    static var gameStarted = false
    
    static func stopGame() {
        gamePlay.gameHasEnded = true
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    //labels
    var scoreLabel: SKLabelNode?
    var gameLabel: SKLabelNode?
   
    //node objs
    var ball : SKSpriteNode?
    var floor : SKSpriteNode?
    var paddle : SKSpriteNode?
    
    //for scoring
    var score = 0
    var blue = 10
    var yellow = 15
    var green = 5
    var count = 0 //to speed up game every 10 impacts
    var brickCalled = 0
    
    //impact categories
    let ballCategory: UInt32 = 0x1 << 1
    let paddleCategory: UInt32 = 0x1 << 2
    let yellowBrickCategory: UInt32 = 0x1 << 3
    let greenBrickCategory: UInt32 = 0x1 << 4
    let blueBrickCategory: UInt32 = 0x1 << 5
    let bottomCategory: UInt32 = 0x1 << 6
    let borderCategory: UInt32 = 0x1 << 7
    
    //scene constructor
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
        setUp()//inital set up
    }
    
    func setUp() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0) //turn off gravity
        self.physicsWorld.contactDelegate = self
        
        //create border to trap the bouncy ball object
        let borderFrame = CGRect(x: -size.width / 2 * 0.88, y: -size.height / 2, width: size.width * 0.88, height: size.height)
        let border = SKPhysicsBody(edgeLoopFrom: borderFrame)
        border.friction = 0
        self.physicsBody = border
        border.mass = 1000000
        border.categoryBitMask = borderCategory
        border.contactTestBitMask = ballCategory
        
        //set up gameOver label
        gameLabel = childNode(withName: "gameLabel") as? SKLabelNode
        gameLabel?.fontSize = 50
        gameLabel?.position = CGPoint(x: 0, y: 100)
        gameLabel?.text = "Touch the screen to start"
        
        //set up scoreLabel
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.fontSize = 50
        scoreLabel?.position = CGPoint(x: -size.width / 2 + 200, y: size.height / 2 - 100)
        scoreLabel?.text = "Score: \(score)"
        
        ball?.position = CGPoint(x: 0, y: 0)
        ball?.physicsBody!.affectedByGravity = false
        ball?.physicsBody!.pinned = false
        ball?.isHidden = false
        ball?.physicsBody!.mass = 1000000
        
        paddle?.physicsBody!.pinned = false
        
        gamePlay.gameHasEnded = false
        gamePlay.gameStarted = false
        
        score = 0
        //adjustYPosition = 150
    }
    
    func startGame() {
        
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
        createBrick(color: "green", adjustYPosition: 350, numRows: 2, category: greenBrickCategory)
        
        //hide gameLabel
        gameLabel?.text = ""
        gameLabel?.isHidden = true
    }
    
    //create bricks
    func createBrick(color: String, adjustYPosition: CGFloat, numRows: Int, category: UInt32) {
        
        brickCalled += 1
        
        //to calculate number of bricks per row
        let tmp_element = SKSpriteNode(imageNamed: "\(color).png")
        tmp_element.size = CGSize(width: 50, height: 20)
        let numberOfElements = Int(size.width * 0.88 / tmp_element.size.width) - 2

        for row in 0...numRows {
            for column in 0...numberOfElements {
                
                let element = SKSpriteNode(imageNamed: "\(color).png")
                element.size = CGSize(width: 50, height: 20)
                element.name = "brick"
                element.physicsBody = SKPhysicsBody(rectangleOf: element.size)
                element.physicsBody?.categoryBitMask = category
                element.physicsBody?.contactTestBitMask = ballCategory //brick collides with ball obj
                element.physicsBody?.affectedByGravity = false
                element.physicsBody?.isDynamic = false
                element.physicsBody?.allowsRotation = false
                element.physicsBody?.mass = 10000000
                addChild(element)

                let elementX = -size.width / 2 + 100 + element.size.width * CGFloat(column)
                let elementY = size.height / 2 - CGFloat(150 * brickCalled) - (element.size.height * CGFloat(row))
                element.position = CGPoint(x: elementX , y: elementY)
            }
        }
    }
    
    //when user touch the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gamePlay.gameHasEnded == false{
            for touch in touches {
                let touchLocation = touch.location(in: self)
                paddle?.position.x = touchLocation.x
                break
            }
        } else {
            let touch = touches.first
            if let location = touch?.location(in: self) {
                let theNodes = nodes(at: location)
                
                //Iterate through all elements on the scene to see if the click event has happened on the "Play/Resume" button
                for node in theNodes {
                    if node.name == "restart" {
                        node.removeFromParent()
                        restartGame()
                        break
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gamePlay.gameStarted == false {
            gamePlay.gameStarted = true
            startGame()
        }
        
        if gamePlay.gameHasEnded == false{
            for touch in touches {
                let touchLocation = touch.location(in: self)
                paddle?.position.x = touchLocation.x
                break
            }
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        
        checkEndGame()
        
        if gamePlay.gameHasEnded == false {
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
                //let randomX = Float.random(in: 0 ..< 100.0)
                //let randomY = Float.random(in: 10 ..< 180)
                //let force = CGVector(dx: CGFloat(50), dy: CGFloat(1000))
                //ball?.physicsBody?.applyForce(force)
            } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == borderCategory {
                audioPlayer.playImpactSound(sound: "impact1")
            } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
                print("Bottom contact has been made.")
                gamePlay.gameHasEnded = true
                gameOver()
            }
            
            count += 1 //Speed up the ball every 10 impacts
            
            if count == 10 {
                speedUp() //speed up the game after every touch
            }
            
        }
    }
    
    func checkEndGame() {
        var countBrick = 0
        for child in self.children{
            if child.name == "brick"{
                countBrick += 1
                break
            }
        }
        
        if countBrick == 0 {
            gamePlay.gameHasEnded = true
            endGame()
        }
    }
    
    func speedUp() {
        ball?.physicsBody!.angularDamping +=  0.001
        ball?.physicsBody!.restitution += 0.0005
        count = 0
    }
    
    //for the falling bricks when game ended
    func gameEndedEffect() {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.0)
        
        for child in self.children{
            if child.name == "brick"{
                child.physicsBody? = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
                child.physicsBody?.affectedByGravity = true
                child.physicsBody?.mass = 10
            }
        }
        
        audioPlayer.playImpactSound(sound: "gameOver")
    }
    
    func endGame() {
        
        ball?.physicsBody!.affectedByGravity = true
        ball?.physicsBody!.pinned = true
        ball?.isHidden = true
        
        paddle?.physicsBody!.pinned = true
        
        scoreLabel?.position = CGPoint(x: 0, y: 200)
    
        showRestartBtn()
        displayLabel(textLabel: "Game Ended")
    }
    
    func gameOver() {
        endGame()
        gameEndedEffect()
        displayLabel(textLabel: "Game Over")
        showRestartBtn()
    }
    
    func showRestartBtn() {
        let restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:75, height:75)
        restartBtn.name = "restart"
        restartBtn.position = CGPoint(x: 0, y: -10)
        addChild(restartBtn)
    }
    
    func displayLabel(textLabel: String){
        gameLabel?.isHidden = false
        gameLabel?.fontSize = 100
        gameLabel?.position = CGPoint(x: 0, y: 100)
        gameLabel?.text = textLabel
    }

    func restartGame() {
        clearNodes()
        setUp()
    }
    
    //clear all brick nodes
    func clearNodes() {
        for child in self.children{
            if child.name == "brick"{
                child.removeFromParent()
            }
        }
    }

}
