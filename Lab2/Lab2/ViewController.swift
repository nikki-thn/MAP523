//
//  ViewController.swift
//  Lab2
//
//  Created by Nikki Truong on 2019-01-16.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var MM = 0
    var SS = 0
    var userInput = 0
    
    @IBOutlet weak var MessageLabel: UILabel!

    @IBOutlet weak var textField: UITextField!
    
    @IBAction func StartHandler(_ sender: Any) {
        if let input = Int(textField.text!) {
            userInput = input;
            
            if (userInput < 1 || userInput > 60) {
                MessageLabel.text = "The number must be between 1 and 60"
            }
            else {
                MM = userInput
                SS = 00
                MessageLabel.text = String(MM) + ":" + String(SS);
            }
        }
        else {
            MessageLabel.text = "Please enter a number from 1 - 60 to start"
        }
    }
    
    @IBAction func PauseHandler(_ sender: Any) {
        
    }
    
    @IBAction func ResetHandler(_ sender: Any) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

