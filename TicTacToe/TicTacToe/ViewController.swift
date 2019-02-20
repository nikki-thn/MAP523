//
//  ViewController.swift
//  TicTacToe
//
//  Created by Alireza Moghaddam on 2019-01-28.
//  Copyright © 2019 Alireza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var activePlayer = 1 //Cross
    var gameState = [0,0,0,0,0,0,0,0,0]
    let winningCombinations = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
    var gameOver = false
    var count = 0
    var winner = 0
    
    //MARK: OUTLETS
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    //MARK: ACTIONS
    @IBAction func buttonTapped(_ sender: AnyObject) {
        
        //Only allows user to play when it is not taken
        if (gameState[sender.tag - 1] == 0) && gameOver == false {
            
            //assign button to the activePlayer
            gameState[sender.tag - 1] = activePlayer
            
            textLabel.text = "Player \(activePlayer) finshed turn"
            count += 1 //check number of square has been played
            sender.setImage(UIImage(named: "player-\(activePlayer).png"), for: [])
            
            if activePlayer == 1 {
                checkWinner()
                activePlayer = 2
            } else {
                checkWinner()
                activePlayer = 1
            }
            
            
            //User touch an taken square
        } else {
            textLabel.text = "Square is already played by player \(gameState[sender.tag - 1])"
        }
    }
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        restartButton.isHidden = true
        restartButton.isUserInteractionEnabled = false
        restartGame()
    }
    
    func checkWinner() {
        // all square taken without winner, draw
        if count == 9 {
            textLabel.text = "Draw"
            gameIsOver()
        } else {
            print(gameState)
            print(count)
            //loop through winning combinations to check for winner
            for combination in winningCombinations {
                if gameState[combination[0]] == activePlayer && gameState[combination[1]] == activePlayer && gameState[combination[2]] == activePlayer  {
                    print(combination)
                    textLabel.text = "Tap to start new game"
                    gameOver = true
                    winner = activePlayer
                    print("winner is \(winner)")
                    gameIsOver()
                }
            }
        }
    }
    
    
    func gameIsOver() {
        
        for case let button as UIButton in self.view.subviews {
            button.setImage(nil, for: [])
            button.isHidden = true
        }
        
        //Game is draw
        if count != 9 {
            restartButton.isHidden = false
            restartButton.isUserInteractionEnabled = true
            restartButton.setImage(UIImage(named: "restart.png"), for: [])
            bottomImage.isHidden = false
            bottomImage.image = UIImage(named: "player-\(winner)-won.png")!
            backgroundImage.image = UIImage(named: "player-\(winner).png")!
        } else {
            restartButton.isHidden = false
            restartButton.isUserInteractionEnabled = true
            restartButton.setImage(UIImage(named: "restart.png"), for: [])
            //bottomImage.isHidden = false
            //bottomImage.image = UIImage(named: "boa.png")!
            backgroundImage.image = UIImage(named: "board.png")!
        }
    }
    
    func restartGame () {
        activePlayer = 1 //Cross
        gameState = [0,0,0,0,0,0,0,0,0]
        gameOver = false
        count = 0
        winner = 0
        
        for case let button as UIButton in self.view.subviews {
            button.setImage(nil, for: [])
            button.isHidden = false
        }
        
        bottomImage.isHidden = true
        restartButton.isHidden = true
        restartButton.isUserInteractionEnabled = false
        backgroundImage.image = UIImage(named: "board.png")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"pink.jpg")!)
    }
}

