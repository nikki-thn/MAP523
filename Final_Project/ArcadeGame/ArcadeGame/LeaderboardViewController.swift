//
//  LeaderboardViewController.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-03-19.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import UIKit
import CoreData

class UserModel {
    var userName: String
    var userScore: Int
    
    init(username: String, userscore: Int){
        userName = username
        userScore = userscore
    }
    
    func toString() -> String {
        return userName + "         \(userScore)\n"
    }
}

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var leaderboardTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUsers()
    }
    
    func fetchUsers() {
        
        var temp: [UserModel] = []
        
        var success = -1
        //insert data into table
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Iterate through database (query from table)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        
        do {
            request.predicate = nil
            let queryResults = try context.fetch(request)
            
            if queryResults.count > 0 {
                for item in queryResults as! [NSManagedObject]{
                    
                    let uname = item.value(forKey: "userName") as? String
                    let uscore = item.value(forKey: "userScore") as? Int
                 //   print(uname)
                 //   print(score)
                    let user = UserModel(username: uname!, userscore: uscore!)
                    temp.append(user)
                }
            } else {
                success = 2
            }
        } catch {
            print("Tables might not exist in the database")
            
            success = 3
        }
        
        var string = "Player            Score\n"
        
        temp.sort(by: {$0.userScore > $1.userScore})
  
        for i in 0...(temp.count - 1){
            print(i)
            string = string + temp[i].toString()
        }
        print(string)
        leaderboardTextLabel.numberOfLines = 10;
        leaderboardTextLabel.text = string
    }
}
