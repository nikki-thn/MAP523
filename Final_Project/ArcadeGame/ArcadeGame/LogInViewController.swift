//
//  LogInViewController.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-03-19.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import UIKit
import CoreData
class LogInViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var continueBtn: SetButtons!
    
    
    @IBOutlet weak var userTextField: UITextField!
    
    
    @IBAction func createUserBtnTapped(_ sender: Any) {
        createUser(userName: userTextField.text!)
        print("Created user")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueBtn.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    func createUser(userName: String){
        
        //insert data into table
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
        //Ready to perform database operations
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        newUser.setValue(userName, forKey: "userName")
        newUser.setValue(0, forKey: "userScore")

        
        
        try context.save()
            textLabel.text = "User created successfully"
            continueBtn.isEnabled = true
            gamePlay.userName = userTextField.text!
        } catch {
            print("Could not save to database")
        }
    }
    
}
