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

//Global variable for game current status ie to keep playing or stop game
struct gamePlay {
    static var gameHasEnded = false
    static var gameStarted = false
    
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
}

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
    
    var komac: SKSpriteNode?
    var border: SKSpriteNode?
    var background: SKSpriteNode?
    
    var score = 0
    var life = 0
    
    let panRec = UIPanGestureRecognizer()
    
    //Contact categories
    let komacCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let cloudCategory: UInt32 = 0x1 << 3
    let obstacleCategory: UInt32 = 0x1 << 4
    let groundCategory: UInt32 = 0x1 << 5
    let extraLiveCategory: UInt32 = 0x1 << 6
    let birdCategory: UInt32 = 0x1 << 7
    let borderCategory: UInt32 = 0x1 << 8
    
    //When game scene is loaded
    override func didMove(to view: SKView) {
        
        //create border to trap the ball object
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        border.mass = 100000
        border.categoryBitMask = borderCategory
        border.contactTestBitMask = komacCategory
        
        panRec.addTarget(self, action: #selector(pan))
        self.view!.addGestureRecognizer(panRec)
        
        setScene()
        startGame()
    }
    
    @objc func pan(_ recognizer : UIPanGestureRecognizer) {
        let view = recognizer.view!
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)

        var vectorLength: CGFloat
        
        //player.velocity = velocity
        
        //print("x: \(translation.x)  y: \(translation.y)")
        print("vel \(velocity)")
        
        if (velocity.y < 0){
            print("up")
            vectorLength = (pow((velocity.x), 2) + pow((velocity.y), 2)).squareRoot()
            
            var vector = CGVector()

            vector = CGVector(dx: (translation.x - komac!.position.x) * vectorLength * 0.02, dy: (translation.y - komac!.position.y) * vectorLength * 0.02)
        
            komac?.physicsBody?.applyForce((vector))
        }
    }
    
    //when touches began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //If the screen is not on "Game Over" mode, then apply the force to komac
        if gamePlay.gameHasEnded == false {
            komac?.physicsBody?.applyForce(CGVector(dx: 0, dy: 30000))
        } else {
            let touch = touches.first
            if let location = touch?.location(in: self) {
                let theNodes = nodes(at: location)

                //Iterate through all elements on the scene to see if the click event has happened on the "Play/Resume" button
                for node in theNodes {
                    if node.name == "restart" {
                        // Restart the game
                        node.removeFromParent()
                        restartGame()
                    }
                }
            }
        }
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
        
        if firstBody.categoryBitMask == komacCategory && secondBody.categoryBitMask == coinCategory {
            secondBody.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
            audioPlayer.playImpactSound(sound: "coin")
        } else if firstBody.categoryBitMask == komacCategory && secondBody.categoryBitMask == birdCategory {
            secondBody.node?.removeFromParent()
            life -= 1
            removeLife(numOfLives: life)
            audioPlayer.playImpactSound(sound: "loseLife")
            if life == 0 {
                scoreLabel?.text = "Score: \(score)"
                clearNodes()
                gameOver()
            }
        } else if firstBody.categoryBitMask == komacCategory && secondBody.categoryBitMask == extraLiveCategory {
            secondBody.node?.removeFromParent()
            life += 1
            addLife(numOfLives: life)
            audioPlayer.playImpactSound(sound: "gainLife")
        }
//        } else if firstBody.categoryBitMask == komacCategory && secondBody.categoryBitMask == borderCategory {
//            print("contact")
//            removeLives()
//            audioPlayer.playImpactSound(sound: "gameOver")
//            clearNodes()
//            gameOver()
//        }
        else if firstBody.categoryBitMask == obstacleCategory && secondBody.categoryBitMask == borderCategory {
            firstBody.node?.removeFromParent()
            print("contact obstacle")
        }
    }
    
    //when restart is touched
    func restartGame() {
        gamePlay.cloudTimer?.invalidate()
        setScene()
        startGame()
    }
    
    //start game
    func startGame() {
        
        //set lives
        for number in 1...life {
            addLife(numOfLives: number)
        }
        
        runKomac() //animated Komac to run
        createGround() //animated ground
        startTimers() //create coins, birds, obstacles, etc
    }
    
    func gameOver() {
        //clearNodes()
        setGameOverScene()
        gamePlay.stopTimer()
    }
    
    //set scene and other element for the game
    func setScene(){
        
        life = 3
        score = 0
        gamePlay.gameStarted = true
        gamePlay.gameHasEnded = false
        
        physicsWorld.contactDelegate = self
        
        komac = childNode(withName: "komac") as? SKSpriteNode
        border = childNode(withName: "border") as? SKSpriteNode
        background = childNode(withName: "background") as? SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        gameLabel = childNode(withName: "gameLabel") as? SKLabelNode
        
        komac?.physicsBody?.categoryBitMask = komacCategory
        komac?.physicsBody?.contactTestBitMask = borderCategory | coinCategory | obstacleCategory | birdCategory | cloudCategory | extraLiveCategory
//        komac?.physicsBody?.collisionBitMask = coinCategory | obstacleCategory | groundCategory | borderCategory
        
        border?.physicsBody?.categoryBitMask = borderCategory
        border?.physicsBody?.contactTestBitMask = obstacleCategory
        border?.physicsBody?.collisionBitMask = komacCategory
        
        gameLabel?.isHidden = true
        scoreLabel?.text = "Score: \(score)"
        scoreLabel?.position = CGPoint(x: -size.width / 2 + 165 , y: size.height / 2 - 150)
    
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: background, action: #selector(swipedRight))
        
        swipeRight.direction = .right
        
        view?.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
        print("Object has been swiped")        
    }
    
    func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        let touch = touches.first as! UITouch
        let location = touch.location(in: self)
        
        if (background?.frame.contains(location))!
        {
            print("Swipe has started")
        }
    }
    
    func runKomac() {
        //To make animated character
        var komacRun : [SKTexture] = []
        for number in 1...4 {
            komacRun.append(SKTexture(imageNamed: "frame-\(number).png"))
        }
        
        //timePerFrame to make it runs faster or slower
        komac?.run(SKAction.repeatForever(SKAction.animate(with: komacRun, timePerFrame: 0.2)))
        komac?.isHidden = false
        komac?.position = CGPoint(x: 0, y: 0)
    }
    
    //to adjust how often an element is created
    func startTimers() {
//
//        gamePlay.coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in self.createCoin()})
//
//        gamePlay.cloudTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createCloud()})
//
//        //bombTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true, block: {(timer) in self.createBomb()})
//
//        gamePlay.obstacleTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createObstacle()})
//
//        gamePlay.extraLiveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: {(timer) in self.createExtraLive()})
//
//       // gamePlay.birdTimer = Timer.scheduledTimer(withTimeInterval: 50, repeats: true, block: { (timer) in
//            self.createBird()})
    }
    
    //create birds
    func createBird() {
        let bird = SKSpriteNode(imageNamed: "bird-1")
        bird.name = "bird"
        bird.size = CGSize(width: 150, height: 70)
        bird.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bird.size.width - 20, height: bird.size.height - 20))
        bird.physicsBody?.affectedByGravity = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = komacCategory
        bird.physicsBody?.mass = 0
        
        addChild(bird)
        
        let maxY = size.height / 2 - bird.size.height / 2
        let minY = -size.height / 2 + bird.size.height / 2
        let range = maxY - minY
        
        let birdY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bird.position = CGPoint(x: size.width / 2 + bird.size.width / 2, y: birdY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bird.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        bird.run(mySeq)
        lastCreatedCoinPosition = CGPoint(x: size.width / 2 + bird.size.width / 2, y: birdY)
        
        //To make animated character
        var birdRun : [SKTexture] = []
        for number in 1...4 {
            birdRun.append(SKTexture(imageNamed: "bird-\(number).png"))
        }
        
        //timePerFrame to make it runs faster or slower
        bird.run(SKAction.repeatForever(SKAction.animate(with: birdRun, timePerFrame: 0.2)))
    }
    
    //create coins
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.name = "coin"
        coin.size = CGSize(width: 100, height: 100)
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = komacCategory
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
        lastCreatedCoinPosition = CGPoint(x: size.width / 2 + coin.size.width / 2, y: coinY)
    }
    
    //create obstables
    func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        obstacle.name = "obstacle"
        obstacle.size = CGSize(width: 300, height: 120)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacle.size.width - 50, height: obstacle.size.height - 10))
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.mass = 1000000

        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = borderCategory
        obstacle.physicsBody?.contactTestBitMask = komacCategory
        
        addChild(obstacle)
        
        let maxY = size.height / 2 - obstacle.size.height / 2
        let minY = -size.height / 2 + obstacle.size.height / 2
        let range = maxY - minY
        
        let obstacleY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        obstacle.position = CGPoint(x: size.width / 2 + obstacle.size.width / 2, y: obstacleY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - obstacle.size.width, y: 0, duration: 3)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        obstacle.run(mySeq)
    }
    
    //create extra lives
    func createExtraLive() {
        if life < 5 {
            let live = SKSpriteNode(imageNamed: "health")
            live.size = CGSize(width: 100, height: 100)
            live.physicsBody = SKPhysicsBody(rectangleOf:  live.size)
            live.physicsBody?.affectedByGravity = false
            live.name = "live"

            live.physicsBody?.categoryBitMask = extraLiveCategory
            live.physicsBody?.contactTestBitMask = komacCategory
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
    
    //create clouds
    func createCloud() {
        let cloud = SKSpriteNode(imageNamed: "cloud")
        cloud.size = CGSize(width: 300, height: 170)
        cloud.physicsBody?.categoryBitMask = cloudCategory
        cloud.physicsBody?.contactTestBitMask = 0
        addChild(cloud)
        
        let maxY = size.height / 2 - cloud.size.height / 3
        let minY = -size.height / 2 + cloud.size.height / 2
        let range = maxY - minY
        
        let cloudY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        cloud.position = CGPoint(x: size.width / 2 + cloud.size.width / 2, y: cloudY + CGFloat(50))
        
        let moveLeft = SKAction.moveBy(x: -size.width - cloud.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        cloud.run(mySeq)
    }
    
    //animated ground
    func createGround() {
        let tmp_element = SKSpriteNode(imageNamed: "ground.jpg")
        let numberOfElements = Int(size.width / tmp_element.size.width) + 1
        
        for number in 0...numberOfElements {
            
            let element = SKSpriteNode(imageNamed: "ground.jpg")
            element.size = CGSize(width: 255, height: 120)
            element.physicsBody = SKPhysicsBody(rectangleOf: element.size)
           // element.physicsBody?.categoryBitMask = groundCategory
           // element.physicsBody?.collisionBitMask = komacCategory
            element.physicsBody?.affectedByGravity = false
            element.physicsBody?.isDynamic = false
            element.physicsBody?.allowsRotation = false
            addChild(element)
            
            let elementX = -size.width / 2 + element.size.width / 2  + element.size.width * CGFloat(number)
            
            element.position = CGPoint(x: elementX, y: -size.height / 2 + element.size.height / 2)
            
            let speed = 100.0
            
            let moveLeft = SKAction.moveBy(x: -element.size.width - element.size.width * CGFloat(number), y: 0, duration: TimeInterval(element.size.width + element.size.width * CGFloat(number)) / speed)
            
            let resetElement = SKAction.moveBy(x: size.width + element.size.width, y: 0, duration: 0)
            
            let fullScreenMove = SKAction.moveBy(x: -size.width - element.size.width, y: 0, duration: TimeInterval(size.width + element.size.width) / speed)
            
            let elementMoveConstantly = SKAction.repeatForever(SKAction.sequence([fullScreenMove, resetElement]))
            
            element.run(SKAction.sequence([moveLeft, resetElement, elementMoveConstantly]))
        }
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
    
    //clear nodes
    func clearNodes() {
        for child in self.children{
            if child.name == "coin" || child.name == "bird" ||
                child.name == "obstacle" || child.name == "live" { // || child.name == "cloud"
                child.removeFromParent()
                break
            }
        }
    }

    // set game over scene
    func setGameOverScene(){
        //scene?.isPaused = true  //Pause the scene
        gamePlay.gameHasEnded = true
        showRestartBtn()
        displayLabel(textLabel: "Game Over")
        komac?.isHidden = true
        scoreLabel?.position = CGPoint(x: 0, y: 200)
    }

    //show the restart btn when game is over
    func showRestartBtn() {
        let restartBtn = SKSpriteNode(imageNamed: "play")
        restartBtn.size = CGSize(width:75, height:75)
        restartBtn.name = "restart"
        restartBtn.position = CGPoint(x: 0, y: 0)
        addChild(restartBtn)
    }
    
    //label to display game over message
    func displayLabel(textLabel: String){
        gameLabel?.isHidden = false
        gameLabel?.fontSize = 100
        gameLabel?.position = CGPoint(x: 0, y: 100)
        gameLabel?.text = textLabel
    }
}
