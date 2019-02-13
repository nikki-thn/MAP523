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
    var msgLabel: SKLabelNode?
    var lastCreatedCoinPosition: CGPoint?
    
    var mario: SKSpriteNode?
    
    var coinTimer: Timer?
    var cloudTimer: Timer?
    var obstacleTimer: Timer?
    var extraLiveTimer: Timer?
    var bombTimer: Timer?
    var birdTimer: Timer?
   
    var score = 0
    var life = 0
    
    let marioCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let obstacleCategory: UInt32 = 0x1 << 4
    let groundCategory: UInt32 = 0x1 << 5
    let extraLiveCategory: UInt32 = 0x1 << 6
    let birdCategory: UInt32 = 0x1 << 7
    
    
    override func didMove(to view: SKView) {
        
        
        physicsWorld.contactDelegate = self
        
        mario = childNode(withName: "mario") as? SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        msgLabel = childNode(withName: "msgLabel") as? SKLabelNode
        
        
        setScreen();
        startTimers();
    }
    
    func setScreen(){
        
        life = 2

        msgLabel?.isHidden = true
        scoreLabel?.text = "Score: \(score)"
        scoreLabel?.position = CGPoint(x: size.width / 2 - 550, y: size.width / 2 + 100)
        
        mario?.physicsBody?.categoryBitMask = marioCategory
        mario?.physicsBody?.collisionBitMask = coinCategory | obstacleCategory | groundCategory
        mario?.physicsBody?.contactTestBitMask = birdCategory
        mario?.physicsBody?.contactTestBitMask = extraLiveCategory
        
        for number in 1...life {
            addLife(numOfLives: number)
        }
        
        
        
        //To make animated character
        var marioRun : [SKTexture] = []
        for number in 1...4 {
            marioRun.append(SKTexture(imageNamed: "frame-\(number).png"))
        }
        
        //timePerFrame to make it runs faster or slower
        mario?.run(SKAction.repeatForever(SKAction.animate(with: marioRun, timePerFrame: 0.2)))
        mario?.isHidden = false
        mario?.position = CGPoint(x: 0, y: 0)
        createGround();
    }
    
    func startTimers() {
        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in self.createCoin()})
        
//        cloudTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createCloud()})
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {(timer) in self.createBomb()})
        
        obstacleTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {(timer) in self.createObstacle()})
        
        extraLiveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: {(timer) in self.createExtraLive()})
        
        birdTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.createBird()
        })
    }
    
    func stopTimer() {
        coinTimer?.invalidate();
        //bombTimer?.invalidate();
        obstacleTimer?.invalidate();
        extraLiveTimer?.invalidate();
        birdTimer?.invalidate();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //mario?.physicsBody?.applyForce(CGVector(dx:0, dy: 50000))

        if scene?.isPaused == false {   //If the screen is not on "Game Over" mode, then apply the force to mario
            mario?.physicsBody?.applyForce(CGVector(dx: 0, dy: 30000))
        }
        
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            
            //Iterate through all elements on the scene to see if the click event has happened on the "Play/Resume" button
            for node in theNodes {
                if node.name == "restart" {
                    // Restart the game
                    score = 0
                    node.removeFromParent()
                    //scoreLabel?.removeFromParent()
                    //lifeLabel?.removeFromParent()
                    scene?.isPaused = false
                    //scoreLabel?.text = "Score: \(score)"
                    setScreen();
                    startTimers()
                }
            }
        }
            
    }
    
    func createBird() {
        let bird = SKSpriteNode(imageNamed: "bird-1")
        bird.name = "bird"
        bird.size = CGSize(width: 150, height: 70)
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.affectedByGravity = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = marioCategory
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
    
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.name = "coin"
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
        lastCreatedCoinPosition = CGPoint(x: size.width / 2 + coin.size.width / 2, y: coinY)
    }
    
    func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        obstacle.name = "obstacle"
        obstacle.size = CGSize(width: 300, height: 100)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacle.size.width - 60, height: obstacle.size.height - 80))
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.mass = 1000000
        
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        //obstacle.physicsBody?.contactTestBitMask = marioCategory
        obstacle.physicsBody?.collisionBitMask = marioCategory
        
        addChild(obstacle)
        
        let maxY = size.height / 2 - obstacle.size.height / 2
        let minY = -size.height / 2 + obstacle.size.height / 2
        let range = maxY - minY
        
        let obstacleY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        obstacle.position = CGPoint(x: size.width / 2 + obstacle.size.width / 2, y: obstacleY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - obstacle.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        obstacle.run(mySeq)
    }
    
    //create CGPoint (last created element
    func createBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.name = "bomb"
        bomb.size = CGSize(width: 100, height: 100)
        bomb.physicsBody = SKPhysicsBody(rectangleOf:  bomb.size)
        bomb.physicsBody?.affectedByGravity = false

        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = marioCategory
        bomb.physicsBody?.mass = 0

        addChild(bomb)

        let maxY = size.height / 2 - bomb.size.height / 2
        let minY = -size.height / 2 + bomb.size.height / 2
        let range = maxY - minY

        var coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))

        while abs(maxY - lastCreatedCoinPosition!.y) < 100
        {
            coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        }


        bomb.position = CGPoint(x: size.width / 2 + bomb.size.width / 2, y: coinY)

        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 4)
        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        bomb.run(mySeq)
    }
    
    func createExtraLive() {
        if life < 5 {
            let live = SKSpriteNode(imageNamed: "health")
            live.size = CGSize(width: 100, height: 100)
            live.physicsBody = SKPhysicsBody(rectangleOf:  live.size)
            live.physicsBody?.affectedByGravity = false
            live.name = "live"
            
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
    
    
    func addLife(numOfLives: Int) {
        let life = SKSpriteNode(imageNamed: "health")
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
    
    func clearNodes() {
        for child in self.children{
            if child.name == "coin" || child.name == "bomb" || child.name == "bird" ||
                child.name == "obstacle"{
                child.removeFromParent()
            }
        }
    }
    
    
//    func createCloud() {
//        let cloud = SKSpriteNode(imageNamed: "cloud")
//        cloud.size = CGSize(width: 300, height: 200)
//
//        addChild(cloud)
//
//        let maxY = size.height / 2 - cloud.size.height / 2
//        let minY = -size.height / 2 + cloud.size.height / 2
//        let range = maxY - minY
//
//        let cloudY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
//
//        cloud.position = CGPoint(x: size.width / 2 + cloud.size.width / 2, y: cloudY)
//
//        let moveLeft = SKAction.moveBy(x: -size.width - cloud.size.width, y: 0, duration: 4)
//        let mySeq = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
//        cloud.run(mySeq)
//    }
    
    func createGround() {
        let tmp_element = SKSpriteNode(imageNamed: "ground.jpg")
        let numberOfElements = Int(size.width / tmp_element.size.width) + 1
        
        for number in 0...numberOfElements {
            
            let element = SKSpriteNode(imageNamed: "ground.jpg")
            element.size = CGSize(width: 255, height: 120)
            element.physicsBody = SKPhysicsBody(rectangleOf: element.size)
            element.physicsBody?.categoryBitMask = groundCategory
            element.physicsBody?.collisionBitMask = marioCategory
            element.physicsBody?.affectedByGravity = false
            element.physicsBody?.isDynamic = false
            element.physicsBody?.allowsRotation = false
            addChild(element)
            
            let elementX = -size.width / 2 + element.size.width / 2  + element.size.width * CGFloat(number)
            
            element.position = CGPoint(x: elementX, y: -size.height / 2 + element.size.height / 2)
            
            let speed = 100.0
            
            let moveLeft = SKAction.moveBy(x: -element.size.width - element.size.width * CGFloat(number), y: 0, duration: TimeInterval(element.size.width + element.size.width * CGFloat(number)) / speed)
            
            let resetElement = SKAction.moveBy(x: size.width + element.size.width, y: 0, duration: 0)
            
            let fullScreenMove = SKAction.moveBy(x: -size.width - element.size.width, y: 0,
                                                 duration: TimeInterval(size.width + element.size.width) / speed)
            
            let elementMoveConstantly = SKAction.repeatForever(SKAction.sequence([fullScreenMove, resetElement]))
            
            element.run(SKAction.sequence([moveLeft, resetElement, elementMoveConstantly]))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //updateScore()

        if contact.bodyB.categoryBitMask == coinCategory {
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        } else if contact.bodyB.categoryBitMask == bombCategory || contact.bodyB.categoryBitMask == birdCategory {
            contact.bodyB.node?.removeFromParent()
            life -= 1
            removeLife(numOfLives: life)
            if life == 0 {
                mario?.isHidden = true
                scoreLabel?.text = "Score: \(score)"
                clearNodes()
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
//
    func gameOver() {
        
        scene?.isPaused = true  //Pause the scene

        //1 - Stop the timers for coin and bird
        stopTimer()
        
        //3 - Update the final score on the screen
        let restartBtn = SKSpriteNode(imageNamed: "play")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.name = "restart"
        restartBtn.isUserInteractionEnabled = false
        addChild(restartBtn)
        restartBtn.position = CGPoint(x: 0, y: 0)
        
        msgLabel?.text = "Game over"
        msgLabel?.position = CGPoint(x: 0, y: 100)
        msgLabel?.fontColor = UIColor.red
        msgLabel?.isHidden = false
        scoreLabel?.position = CGPoint(x: 0, y: 200)
    }
}

