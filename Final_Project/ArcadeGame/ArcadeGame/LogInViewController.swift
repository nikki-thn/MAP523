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
    @IBOutlet weak var createBtn: SetButtons!
    @IBOutlet weak var userTextField: UITextField!
    
    
    @IBAction func createUserBtnTapped(_ sender: Any) {
        
        var errCode = -1
        errCode = fetchUser(userName: userTextField.text!)
        
        if errCode == 0 {
            print("Log in successfully")
            textLabel.text! = "User already exist. Please continue"
            gamePlay.userName = userTextField.text!
            createBtn.isEnabled = false
            continueBtn.isEnabled = true
        } else if errCode == 2 {
            createUser(userName: userTextField.text!)
            print("Created user")
            createBtn.isEnabled = false
            continueBtn.isEnabled = true
            gamePlay.userName = userTextField.text!
        } else if errCode == 3 {
            textLabel.text! = "Error in the database"
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueBtn.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    
    func fetchUser(userName: String) -> Int {
        
        var errCode = 0
        //insert data into table
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Iterate through database (query from table)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        
        do {
            request.predicate = NSPredicate(format: "userName = %@ ", userName)
            let queryResults = try context.fetch(request)
            
            if queryResults.count > 0 {
                for item in queryResults as! [NSManagedObject]{
                    
                    let uname = item.value(forKey: "userName") as? String
                    if uname != "" {
                        errCode = 0
                        print("User found")
                    }
                }
            } else {
                errCode = 2
                print("User not found, create user")
            }
        } catch {
            print("Tables might not exist in the database")
            errCode = 3
        }
        
        return errCode
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
        } catch {
            print("Could not save to database")
        }
    }
    
}
