//
//  ViewController.swift
//  Lab6
//
//  Created by Nikki on 3/6/19.
//  Copyright © 2019 Nikki. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBAction func btnTapped(_ sender: Any) {
       
        var stage = -1
        stage = fetchUser(userName: userNameTextField.text!, password: passwordTextField!.text!)
        if stage == 0 {
            print("Log in successfully")
        } else if stage == 1 {
            msgLabel.text = "Password is incorrect"
        } else if stage == 2 {
            btn.isUserInteractionEnabled = false
            registerBtn.isEnabled = true
            msgLabel.text = "User does not exit. Please register"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //registerBtn.isUserInteractionEnabled = false
        registerBtn.isEnabled = false
    }
    
    func fetchUser(userName: String, password: String) -> Int {
        
        var success = -1
        //insert data into table
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Iterate through database (query from table)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        
        do {
            request.predicate = NSPredicate(format: "username = %@ ", userName)
            //or %i , 80 without quotation mark
            let queryResults = try context.fetch(request)
            
            if queryResults.count > 0 {
                for item in queryResults as! [NSManagedObject]{
                    
                    let uname = item.value(forKey: "username") as? String
                    let pword = item.value(forKey: "password") as? String
                    if uname != "" {
                        if pword == password {
                            success = 0
                            msgLabel.text = "Hello " + userName
                        } else {
                            success = 1
                            print("password is in correct")
                        }
                    }
                }
            } else {
                success = 2
            }
        } catch {
            print("Tables might not exist in the database")
            
            success = 3
        }
        
        return success
    }

}

