//
//  ViewController.swift
//  Lab1:
/*
    Create 2 labels and a button, everytime button is touched
        label1 increase by one and reset to 0 when reaches 9
    When button 1 reaches 9 then increase the label2 by one
*/
//  Created by Nikki Truong on 2019-01-09.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var counter1 = 0; //Counter for label1
    var counter2 = 0; //Counter for label2
    
    @IBOutlet weak var Label1: UILabel!
    
    @IBOutlet weak var Label2: UILabel!
    
    //Handler for button Increase
    @IBAction func Button(_ sender: Any) {
        
        //Increate counter1 everytime button is touched
        counter1 = counter1 + 1;
        
        //Assign value to Label1
        Label1.text = String(counter1);
        
        //When counter when is greater than 9
        if (counter1 > 9){
            
            //Increase counter2 by 1
            counter2 = counter2 + 1;
            
            //Reset counter1
            counter1 = 0;
            
            //Assign new values to the labels
            Label1.text = String(counter1);
            Label2.text = String(counter2);
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

