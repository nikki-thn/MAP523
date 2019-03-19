//
//  GameScene.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-02-19.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//
//  Last Modified: March 12, 2019


import SpriteKit
import GameplayKit
import CoreData

//Global variable for game current status ie to keep playing or stop game
struct gamePlay {
    static var gameHasEnded = false
    static var gameStarted = false
    //static var paddle : SKSpriteNode?
    
    static var userName = ""
    static var userScore = 0
    
    static var coinTimer: Timer?
    static var cloudTimer: Timer?
    static var obstacleTimer: Timer?
    static var extraLiveTimer: Timer?
    static var bombTimer: Timer?
    static var birdTimer: Timer?
    
    //stop creating new elements
    static func stopTimer() {
        gamePlay.coinTimer?.invalidate()
        gamePlay.obstacleTimer?.invalidate()
        gamePlay.extraLiveTimer?.invalidate()
        gamePlay.birdTimer?.invalidate()
    }
    
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
    
    //var floor : SKSpriteNode?
    var paddle : SKSpriteNode?
    
    //for scoring
    var score = 0
    var blue = 10
    var yellow = 15
    var green = 5
    var count = 0 //to speed up game every 10 impacts
    var brickCalled = 0
    var lastCreatedCoinPosition: CGPoint?
    
    //impact categories
    let bulletCategory: UInt32 = 0x1 << 1
    let paddleCategory: UInt32 = 0x1 << 2
    let blueShipCategory: UInt32 = 0x1 << 3
    let greenBrickCategory: UInt32 = 0x1 << 4
    let blueBrickCategory: UInt32 = 0x1 << 5
    let coinCategory: UInt32 = 0x1 << 6
    let borderCategory: UInt32 = 0x1 << 7
    
    //scene constructor
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
        setUp()//inital set up
    }
    
    //to adjust how often an element is created
    func startTimers(timeInterval: Double) {
        
        gamePlay.coinTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: {(timer) in self.createBlueShips()})
//
//        gamePlay.cloudTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createCloud()})
        
//        gamePlay.obstacleTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createObstacle()})
//
//        gamePlay.extraLiveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: {(timer) in self.createExtraLive()})
        
//        gamePlay.birdTimer = Timer.scheduledTimer(withTimeInterval: 50, repeats: true, block: { (timer) in
//            self.createBird()})
    }
    
    func setUp() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0) //turn off gravity
        self.physicsWorld.contactDelegate = self
        
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
        
        
        //declare the nodes
        paddle = childNode(withName: "paddle") as? SKSpriteNode

        //contact categories
        paddle?.physicsBody!.categoryBitMask = paddleCategory
        paddle?.physicsBody!.contactTestBitMask = coinCategory
        paddle?.physicsBody!.contactTestBitMask = greenBrickCategory
        paddle?.physicsBody!.contactTestBitMask = blueBrickCategory
        paddle?.physicsBody!.collisionBitMask = blueShipCategory
        paddle?.position = CGPoint(x: 0, y: -size.height / 2 + 100)
        paddle?.physicsBody!.pinned = false
        
        gamePlay.gameHasEnded = false
        gamePlay.gameStarted = false
        
        score = 0
        //adjustYPosition = 150
    }
    
    func startGame() {

        //hide gameLabel
        gameLabel?.text = ""
        gameLabel?.isHidden = true
        
        startTimers(timeInterval:  1)
    }
    
    //Create blue ships
    func createBlueShips() {
        let blueShip = SKSpriteNode(imageNamed: "blueship")
        blueShip.name = "coin"
        blueShip.size = CGSize(width: 100, height: 100)
        blueShip.physicsBody = SKPhysicsBody(rectangleOf: blueShip.size)
        blueShip.physicsBody?.affectedByGravity = false
        
        blueShip.physicsBody?.categoryBitMask = blueShipCategory
        blueShip.physicsBody?.contactTestBitMask = bulletCategory
        blueShip.physicsBody?.contactTestBitMask = paddleCategory
        blueShip.physicsBody?.mass = 0
        
        addChild(blueShip)
        
        let maxX = size.width / 2 - blueShip.size.width / 2
        let minX = -size.width / 2 + blueShip.size.width / 2
        let range = maxX - minX
        
        let coinX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        
        blueShip.position = CGPoint(x: coinX, y: size.height / 2 + blueShip.size.height / 2 )
        
        let moveUp = SKAction.moveBy(x: 0, y: -size.height - blueShip.size.height, duration: 4)
        let mySeq = SKAction.sequence([moveUp, SKAction.removeFromParent()])
        blueShip.run(mySeq)
        lastCreatedCoinPosition = CGPoint(x: coinX, y: size.height / 2 + blueShip.size.height / 2)
    }
    
    //create bricks
    func createBrick(color: String, adjustYPosition: CGFloat, numRows: Int, category: UInt32) {
        
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
                //set contact of bricks and the ball
                element.physicsBody?.contactTestBitMask = bulletCategory
                element.physicsBody?.affectedByGravity = false
                element.physicsBody?.restitution = 1
                element.physicsBody?.allowsRotation = false
                element.physicsBody?.mass = 10000000
                addChild(element)

                let elementX = -size.width / 2 + 100 + element.size.width * CGFloat(column)
                let elementY = size.height / 2 - CGFloat(adjustYPosition) - (element.size.height * CGFloat(row))
                element.position = CGPoint(x: elementX , y: elementY)
            }
        }
    }
    
    func createBullet() {
        let projectile = SKSpriteNode(imageNamed: "bullet")
        projectile.zPosition = 1
        projectile.position = CGPoint(x: paddle?.position.x ?? 0, y: paddle?.position.y ?? 0)
        projectile.size = CGSize(width: 20, height: 20)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.mass = 100
        projectile.physicsBody?.categoryBitMask = bulletCategory
        projectile.physicsBody?.contactTestBitMask = blueShipCategory
        projectile.physicsBody?.collisionBitMask = blueShipCategory
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(projectile)
        
        let action = SKAction.moveTo(y: self.frame.height, duration: 1)
        projectile.run(action)
    }
    
    //when user touch the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gamePlay.gameHasEnded == false{
            for touch in touches {
                let touchLocation = touch.location(in: self)
                paddle?.position.x = touchLocation.x
                createBullet()
                break
            }
        } else {
            let touch = touches.first
            if let location = touch?.location(in: self) {
                let theNodes = nodes(at: location)
                
                //Iterate through all elements on the scene to see if the click event has happened on the "Play/Resume" button
                for node in theNodes {
                    if node.name == "restart" {
                        print("restart is pressed")
                        node.removeFromParent()
                        removeRestartBtn()
                        restartGame()
                        break
                    }
                }
            }
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //user touch to start the game
        if gamePlay.gameStarted == false {
            gamePlay.gameStarted = true
            startGame()
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gamePlay.gameHasEnded == false {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            // Identify bodies of contacts
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            // Check for collisions
            if firstBody.categoryBitMask == bulletCategory && secondBody.categoryBitMask == blueShipCategory {
                secondBody.node?.removeFromParent()
                score += yellow
                scoreLabel?.text = "Score: \(score)"
                print("Yellow contact has been made.")
                audioPlayer.playImpactSound(sound: "impact2")
            } else if firstBody.categoryBitMask == paddleCategory && secondBody.categoryBitMask == blueShipCategory {
                secondBody.node?.removeFromParent()
                gameOver()
                print("Blue contact has been made.")
                audioPlayer.playImpactSound(sound: "impact2")
            } else if firstBody.categoryBitMask == bulletCategory && secondBody.categoryBitMask == greenBrickCategory {
                secondBody.node?.removeFromParent()
                score += green
                scoreLabel?.text = "Score: \(score)"
                print("Green contact has been made.")
                audioPlayer.playImpactSound(sound: "impact2")
            }
            
//            count += 1 //Speed up the ball every 10 impacts
//
//            if count == 3 {
//                speedUp() //speed up the game after every touch
//            }
        }
    }
    
    //spued up the game
//    func speedUp() {
//        gamePlay.paddle?.physicsBody!.angularDamping +=  0.001
//        gamePlay.paddle?.physicsBody!.restitution += 0.0005
//        count = 0
//    }
//
    
    //for the falling bricks when game ended
    func gameEndedEffect() {
        audioPlayer.playImpactSound(sound: "gameOver")
    }
    
    //set end game scene
    func setEndGame() {
        
        paddle?.position = CGPoint(x: -size.width / 2, y: -size.height / 2)
        paddle?.physicsBody!.pinned = true
        paddle?.isHidden = true
        paddle?.physicsBody!.pinned = true
        
        scoreLabel?.position = CGPoint(x: 0, y: 200)
    }
    
    //for when user clears all the bricks
    func gameIsFinished() {
        showRestartBtn()
        setEndGame()
        displayLabel(textLabel: "Level completed!")
        showRestartBtn()
    }
    
    //game over ball touched the floor
    func gameOver() {
        setEndGame()
        gameEndedEffect()
        displayLabel(textLabel: "Game Over")
        showRestartBtn()
        saveScore()
    }
    
    func saveScore() {

        //insert data into table
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "userName = %@", gamePlay.userName)
        
        //To update a value in the database
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                
                for item in results as! [NSManagedObject] {
                    if let username = item.value(forKey: "userName") as? String {
                        
                        item.setValue(score, forKey: "userScore")
                        do {
                            try context.save()      //Make sure that you call context.save() everytime
                            print("\(username) has been updated")
                        }
                        catch {
                            print("Error saving user score")
                        }
                        
                    }
                }
            }
            
        }
        catch {
            print("Error")
        }
    }
    
    //show Restart button when game ended
    func showRestartBtn() {
        let restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:75, height:75)
        restartBtn.name = "restart"
        restartBtn.position = CGPoint(x: 0, y: -10)
        addChild(restartBtn)
    }
    
    //remove restart btn
    func removeRestartBtn() {
        for child in self.children{
            if child.name == "restart"{
                child.removeFromParent()
            }
        }
    }
    
    //Set text for game label
    func displayLabel(textLabel: String){
        gameLabel?.isHidden = false
        gameLabel?.fontSize = 100
        gameLabel?.position = CGPoint(x: 0, y: 100)
        gameLabel?.text = textLabel
    }

    //start a new game
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
