//
//  ViewController.swift
//  Lab2
//
//  Created by Nikki Truong on 2019-01-22.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    var totalSeconds = 0
    var minutes = 0
    var timer = Timer()
    var userInput = 0
    
    @IBAction func resetButonTapped(_ sender: Any) {
        timer.invalidate()
        totalSeconds = 0
        timerLabel.text = "MM:SS"
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        if (pauseButton.titleLabel?.text == "Pause") {
            timer.invalidate()
            pauseButton.setTitle("Resume", for: UIControl.State.normal)
        } else {
            pauseButton.setTitle("Pause", for: UIControl.State.normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.runTimer), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        
        if let input = Int(textField.text!) {
            userInput = input;
            
            if (userInput < 1 || userInput > 60) {
                messageLabel.text = "The number must be between 1 and 60"
            }
            else {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.runTimer), userInfo: nil, repeats: true)
                totalSeconds = userInput * 60;
            }
        }
        else {
            messageLabel.text = "Input must be a number from 1 - 60"
        }
        
   
    }
    
    @objc func runTimer() {
        totalSeconds -= 1
        let minutes = Int(TimeInterval(totalSeconds)) / 60 % 60
        let seconds = Int(TimeInterval(totalSeconds)) % 60
        timerLabel.text = String(format:"%02i:%02i", minutes, seconds)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

/*
 Credits:
 https://www.youtube.com/watch?v=fZx29HOcHzY
 https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f
 */
