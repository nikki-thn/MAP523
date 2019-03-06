//
//  RegisterViewController.swift
//  Lab6
//
//  Created by Nikki on 3/6/19.
//  Copyright © 2019 Nikki. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {

    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    
    @IBAction func registerBtn(_ sender: Any) {
       createUser(userName: userNameTextField.text!, password: passwordTextField.text!, Age: ageTextField.text!, Address: addressTextField.text!)
        print("Created user")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createUser(userName: String, password: String, Age: String, Address: String){
        
        //insert data into table
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Ready to perform database operations
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        newUser.setValue(userName, forKey: "username")
        newUser.setValue(password, forKey: "password")
        newUser.setValue(Age, forKey: "age")
        newUser.setValue(Address, forKey: "address")
        
        do {
            try context.save()
            msgLabel.text = "User created successfully"
        } catch {
            print("Could not save to database")
        }
    }
}
