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
    static var score = 0
    
    static var coinTimer: Timer?
    static var cloudTimer: Timer?
    static var orangeShipTimer: Timer?
    static var extraLiveTimer: Timer?
    static var bombTimer: Timer?
    static var birdTimer: Timer?
    
    //stop creating new elements
    static func stopTimer() {
        gamePlay.coinTimer?.invalidate()
        gamePlay.orangeShipTimer?.invalidate()
        gamePlay.extraLiveTimer?.invalidate()
        gamePlay.birdTimer?.invalidate()
    }
    
    static func stopGame() {
        gamePlay.gameHasEnded = true
    }
    
    static func saveScore() {
        
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
    
    var floor : SKSpriteNode?
    var paddle : SKSpriteNode?
    
    //for scoring
    //var score = 0
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
    let cloudCategory: UInt32 = 0x1 << 4
    let blueBrickCategory: UInt32 = 0x1 << 5
    let coinCategory: UInt32 = 0x1 << 6
    let orangeShipCategory: UInt32 = 0x1 << 7
    
    //scene constructor
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
//        let background = SKSpriteNode(imageNamed: "background.png")
//        background.position = CGPoint(x: 0, y: 0)
//        addChild(background)
        
        setUp()//inital set up
    }
    
    //to adjust how often an element is created
    func startTimers() {
        
        gamePlay.coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in self.createBlueShips()})
        
        gamePlay.orangeShipTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {(timer) in self.createOrangeShips()})
//
        gamePlay.cloudTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: {(timer) in self.createCloud()})
        
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
        scoreLabel?.text = "Score: \(gamePlay.score)"
        
        
        //declare the nodes
        paddle = childNode(withName: "paddle") as? SKSpriteNode

        //contact categories
        paddle?.physicsBody!.categoryBitMask = paddleCategory
        //paddle?.physicsBody!.contactTestBitMask = coinCategory
        //paddle?.physicsBody!.contactTestBitMask = greenBrickCategory
        //paddle?.physicsBody!.collisionBitMask = oraCategory
        paddle?.physicsBody!.collisionBitMask = blueShipCategory
        paddle?.physicsBody!.collisionBitMask = orangeShipCategory
        paddle?.position = CGPoint(x: 0, y: -size.height / 2 + 100)
        paddle?.physicsBody!.pinned = false
        paddle?.isHidden = false
        
        gamePlay.gameHasEnded = false
        gamePlay.gameStarted = false
        
        gamePlay.score = 0
    }
    
    func startGame() {

        //hide gameLabel
        gameLabel?.text = ""
        gameLabel?.isHidden = true
        
        startTimers()
    }
    
    //create clouds
    func createCloud() {
        let cloud = SKSpriteNode(imageNamed: "planet1")
        cloud.size = CGSize(width: 150, height: 150)
        cloud.physicsBody?.categoryBitMask = cloudCategory
        cloud.physicsBody?.contactTestBitMask = 0
        addChild(cloud)
        
        let maxY = size.height / 2 - cloud.size.height / 3
        let minY = -size.height / 2 + cloud.size.height / 2
        let range = maxY - minY
        
        let cloudY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        cloud.position = CGPoint(x: size.width / 2 + cloud.size.width / 2, y: cloudY + CGFloat(50))
        
        let moveLeft = SKAction.moveBy(x: -size.width - cloud.size.width, y: 0, duration: 20)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        cloud.run(mySeq)
    }
    
    //Create blue ships
    func createBlueShips() {
        let ship = SKSpriteNode(imageNamed: "blueship")
        ship.name = "ship"
        ship.size = CGSize(width: 100, height: 100)
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.affectedByGravity = false
        
        ship.physicsBody?.categoryBitMask = blueShipCategory
       // ship.physicsBody?.contactTestBitMask = bulletCategory
        //ship.physicsBody?.contactTestBitMask = paddleCategory
        ship.physicsBody?.mass = 100
        ship.physicsBody?.allowsRotation = false
        
        addChild(ship)
        
        let maxX = size.width / 2 - ship.size.width / 2
        let minX = -size.width / 2 + ship.size.width / 2
        let range = maxX - minX
        
        let coinX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        
        ship.position = CGPoint(x: coinX, y: size.height / 2 + ship.size.height / 2 )
        
        let moveUp = SKAction.moveBy(x: 0, y: -size.height - ship.size.height, duration: 4)
        let mySeq = SKAction.sequence([moveUp, SKAction.removeFromParent()])
        ship.run(mySeq)
        lastCreatedCoinPosition = CGPoint(x: coinX, y: size.height / 2 + ship.size.height / 2)
    }
    
    //create orange ships
    func createOrangeShips() {
        let ship = SKSpriteNode(imageNamed: "orangeship")
        ship.name = "ship"
        ship.size = CGSize(width: 75, height: 75)
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.affectedByGravity = false
        
        ship.physicsBody?.categoryBitMask = orangeShipCategory
      //  ship.physicsBody?.contactTestBitMask = bulletCategory
      //  ship.physicsBody?.contactTestBitMask = paddleCategory
        ship.physicsBody?.mass = 100
        ship.physicsBody?.allowsRotation = false
        
        
        addChild(ship)
        
        let maxX = size.width / 2 - ship.size.width / 2
        let minX = -size.width / 2 + ship.size.width / 2
        let range = maxX - minX
        
        let coinX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        
        ship.position = CGPoint(x: coinX, y: size.height / 2 + ship.size.height / 2 )
        
        let moveUp = SKAction.moveBy(x: 0, y: -size.height - ship.size.height, duration: 10)
        let mySeq = SKAction.sequence([moveUp, SKAction.removeFromParent()])
        ship.run(mySeq)
//        lastCreatedCoinPosition = CGPoint(x: coinX, y: size.height / 2 + blueShip.size.height / 2)
    }
    
    func createBullet() {
        let projectile = SKSpriteNode(imageNamed: "bullet")
        projectile.zPosition = 1
        projectile.position = CGPoint(x: paddle?.position.x ?? 0, y: paddle?.position.y ?? 0)
        projectile.size = CGSize(width: 20, height: 20)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.mass = 0
        projectile.physicsBody?.categoryBitMask = bulletCategory
        projectile.physicsBody?.contactTestBitMask = blueShipCategory
        projectile.physicsBody?.collisionBitMask = blueShipCategory
        projectile.physicsBody?.contactTestBitMask = orangeShipCategory
        projectile.physicsBody?.collisionBitMask = orangeShipCategory
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(projectile)
        
        let action = SKAction.moveTo(y: self.frame.height, duration: 1)
        projectile.run(action)
    }
    
    //when user touch the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //user touch to start the game
        if gamePlay.gameStarted == false {
            gamePlay.gameStarted = true
            startGame()
        }
        
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
//        //user touch to start the game
//        if gamePlay.gameStarted == false {
//            gamePlay.gameStarted = true
//            startGame()
//        }
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
                gamePlay.score += yellow
                scoreLabel?.text = "Score: \(gamePlay.score)"
                print("Yellow contact has been made.")
                audioPlayer.playImpactSound(sound: "impact2")
            } else if firstBody.categoryBitMask == bulletCategory && secondBody.categoryBitMask == orangeShipCategory {
                count += 1
                if count == 3 {
                    secondBody.node?.removeFromParent()
                    gamePlay.score += green
                    scoreLabel?.text = "Score: \(gamePlay.score)"
                    print("Green contact has been made.")
                    count = 0
                }
                audioPlayer.playImpactSound(sound: "impact2")
            } else if firstBody.categoryBitMask == paddleCategory && (secondBody.categoryBitMask == blueShipCategory || secondBody.categoryBitMask == orangeShipCategory ) {
                secondBody.node?.removeFromParent()
                gameOver()
                print("Blue contact has been made.")
                audioPlayer.playImpactSound(sound: "impact2")
            }
        
           // count += 1 //Speed up the ball every 10 impacts
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
    
    //set end game scene
    func setEndGame() {
        
        paddle?.position = CGPoint(x: -size.width / 2, y: -size.height / 2)
        paddle?.physicsBody!.pinned = true
        paddle?.isHidden = true
        
        scoreLabel?.position = CGPoint(x: 0, y: 200)
        gamePlay.gameHasEnded = true
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
        displayLabel(textLabel: "Game Over")
        showRestartBtn()
        gamePlay.stopTimer()
        gamePlay.saveScore()
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
            if child.name == "ship"{
                child.removeFromParent()
            }
        }
    }

}
