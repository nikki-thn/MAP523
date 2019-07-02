//
//  GameScene.swift
//  Komac
//
//  Created by Nikki Truong on 2019-03-03.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//
//  Last Modified March 12, 2019

/* Features to be worked on:
 1. Stop the game and back to main
 2. Leaderboard and store user data to core data
*/

/* Things to make better:
 1. Seque handling
*/
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    //Declare variables
    var scoreLabel: SKLabelNode?
    var gameLabel: SKLabelNode?
    var lastCreatedCoinPosition: CGPoint?
    
    var leftBottom: SKSpriteNode?
    var rightBottom: SKSpriteNode?
    var middleBottom: SKSpriteNode?
    
    var score = 0
    var life = 0
    
    //let panRec = UIPanGestureRecognizer()
    
    var alphabetTimer: Timer?
    var timeInterval = 5
    
    //Contact categories
    let AIalphabetCategory: UInt32 = 0x1 << 1
    let IRalphabetCategory: UInt32 = 0x1 << 2
    let RZalphabetCategory: UInt32 = 0x1 << 3
    let leftBottomCategory: UInt32 = 0x1 << 4
    let rightBottomCategory: UInt32 = 0x1 << 5
    let middleBottomCategory: UInt32 = 0x1 << 6
    
    let swipeRec = UISwipeGestureRecognizer()

    //start game
    func startGame() {
        
        //set lives
        for number in 1...life {
            addLife(numOfLives: number)
        }
    }
    
    //set scene and other element for the game
    func setScene(){
        
        life = 3
        score = 0
        
        physicsWorld.contactDelegate = self
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        gameLabel = childNode(withName: "gameLabel") as? SKLabelNode
        
        rightBottom = childNode(withName: "rightBottom") as? SKSpriteNode
        rightBottom?.physicsBody!.categoryBitMask = rightBottomCategory
        rightBottom?.physicsBody!.contactTestBitMask = AIalphabetCategory

        leftBottom = childNode(withName: "leftBottom") as? SKSpriteNode
        leftBottom?.physicsBody!.categoryBitMask = leftBottomCategory
        leftBottom?.physicsBody!.contactTestBitMask = RZalphabetCategory
        
        middleBottom = childNode(withName: "middleBottom") as? SKSpriteNode
        middleBottom?.physicsBody!.categoryBitMask = middleBottomCategory
        middleBottom?.physicsBody!.contactTestBitMask = IRalphabetCategory
        
        gameLabel?.isHidden = true
        scoreLabel?.text = "Score: \(score)"
        scoreLabel?.position = CGPoint(x: -size.width / 2 + 165 , y: size.height / 2 - 150)
        
        alphabetTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: true, block: {(timer) in self.createAlphabets()})
    }
    
    @objc func leftSwipe(){
        for child in self.children{
            if child.name == "AIletter" || child.name == "IRletter" {
                child.position.x = -200
                break
            }
        }
    }
    
    @objc func rightSwipe(){
        for child in self.children{
            if child.name == "AIletter" || child.name == "IRletter" {
                child.position.x = 200
                break
            }
        }
    }
    
    @objc func downSwipe(){
        for child in self.children{
            if child.name == "AIletter" || child.name == "IRletter" {
                child.position.x = 0
                break
            }
        }
    }

    func createAlphabets() {
        
        let randNumForLetter = Int.random(in: 1 ... 18)
        var letter = SKSpriteNode(imageNamed: "close")
        
        if randNumForLetter <= 9 {
//
//            letter.texture = SKTexture(imageNamed: "letterA")
            letter = createAILetters()
        } else if randNumForLetter > 9 &&  randNumForLetter <= 18 {
//            letter.physicsBody?.categoryBitMask = IRalphabetCategory
//            letter.texture = SKTexture(imageNamed: "letterD")
            letter = createRILetters()
        } else if randNumForLetter > 18 &&  randNumForLetter <= 24 {
//            letter.physicsBody?.categoryBitMask = RZalphabetCategory
//            letter.texture = SKTexture(imageNamed: "letterG")
        }
    
        addChild(letter)
        
        let maxX = size.width / 2 - letter.size.width / 2
        let minX = -size.width / 2 + letter.size.width / 2
        let range = maxX - minX
        
        let coinX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        
        letter.position = CGPoint(x: coinX, y: size.height / 2 + letter.size.height / 2 )
        
        let moveUp = SKAction.moveBy(x: 0, y: -size.height - letter.size.height, duration: 10)
        let mySeq = SKAction.sequence([moveUp, SKAction.removeFromParent()])
        letter.run(mySeq)
        
       // alphabetTimer?.invalidate()
    }
    
    func createAILetters() -> SKSpriteNode {
        let letter = SKSpriteNode(imageNamed: "letterA")
        
        letter.name = "AIletter"
        letter.size = CGSize(width: 75, height: 75)
        letter.physicsBody = SKPhysicsBody(rectangleOf: letter.size)
        letter.physicsBody?.affectedByGravity = false
        letter.physicsBody?.usesPreciseCollisionDetection = true
        letter.physicsBody?.mass = 100
        letter.physicsBody?.allowsRotation = false
        letter.physicsBody?.categoryBitMask = AIalphabetCategory
        
        return letter
    }
    
    func createRILetters() -> SKSpriteNode {
        let letter = SKSpriteNode(imageNamed: "letterD")
        
        letter.name = "IRletter"
        letter.size = CGSize(width: 75, height: 75)
        letter.physicsBody = SKPhysicsBody(rectangleOf: letter.size)
        letter.physicsBody?.affectedByGravity = false
        letter.physicsBody?.usesPreciseCollisionDetection = true
        letter.physicsBody?.mass = 100
        letter.physicsBody?.allowsRotation = false
        letter.physicsBody?.categoryBitMask = IRalphabetCategory
        
        return letter
    }
    
    //when touches began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)

            //Iterate through all elements on the scene to see if the click event has happened on the "Play/Resume" button
            for node in theNodes {
                if node.name == "restart" {
                    // Restart the game
                    node.removeFromParent()
                    //restartGame()
                }
            }
        }
    }
    
    //When game scene is loaded
    override func didMove(to view: SKView) {
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(leftSwipe))
        left.direction = .left
        self.view!.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(rightSwipe))
        right.direction = .right
        self.view!.addGestureRecognizer(right)
        
        let down = UISwipeGestureRecognizer(target : self, action : #selector(downSwipe))
        down.direction = .down
        self.view!.addGestureRecognizer(down)
        
        setScene()
        startGame()
    }

    //Check for contacts
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
        
        print("First body: \(firstBody.categoryBitMask)")
        print("Second body: \(secondBody.categoryBitMask)")
        print("rightBottomCategory body: \(rightBottomCategory)")
        print("AIalphabetCategory body: \(AIalphabetCategory)")
       
        if firstBody.categoryBitMask == AIalphabetCategory && secondBody.categoryBitMask == rightBottomCategory {
            print("First body: \(firstBody.categoryBitMask)")
            print("Second body: \(secondBody.categoryBitMask)")
            firstBody.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
            print("Correct Right Bottom Contact obstacle")
        } else if firstBody.categoryBitMask == IRalphabetCategory && secondBody.categoryBitMask == middleBottomCategory {
            print("First body: \(firstBody.categoryBitMask)")
            print("Second body: \(secondBody.categoryBitMask)")
            firstBody.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
            print("Correct Middle Bottom Contact obstacle")
        } else if firstBody.categoryBitMask == RZalphabetCategory && secondBody.categoryBitMask == leftBottomCategory {
            print("First body: \(firstBody.categoryBitMask)")
            print("Second body: \(secondBody.categoryBitMask)")
            firstBody.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
             print("Correct Left Bottom Contact obstacle")
        } else {
            life -= 1
            removeLife(numOfLives: life)
            if life == 0 {
                scoreLabel?.text = "Score: \(score)"
            }
            print("Incorrect contact")
        }
    }
    
    //when restart is touched
    func restartGame() {
        setScene()
        startGame()
    }

    //add life
    func addLife(numOfLives: Int) {
        let life = SKSpriteNode(imageNamed: "health")
        life.size = CGSize(width: 75, height: 75)
        life.position = CGPoint(x: -300 + numOfLives * 60, y: Int(size.height / 2 - 85))
        print(numOfLives)
        life.name = "live\(numOfLives)"
        addChild(life)
    }
    
    //remove life
    func removeLife(numOfLives: Int) {
        for child in self.children{
            if child.name == "live\(numOfLives + 1)"{
                child.removeFromParent()
                break
            }
        }
    }
    
    //remove all lives when user hit side border
    func removeLives(){
        for number in 0...life {
            removeLife(numOfLives: number)
        }
    }
}
