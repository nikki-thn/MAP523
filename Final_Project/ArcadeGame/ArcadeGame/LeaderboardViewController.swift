//
//  LeaderboardViewController.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-03-19.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import UIKit
import CoreData
class LeaderboardViewController: UIViewController {

    @IBOutlet weak var leaderboardTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUsers()
    }
    
    func fetchUsers() {
        
        var temp: [String] = []
        
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
                    let score = item.value(forKey: "userScore") as? Int
                 //   print(uname)
                 //   print(score)
                    temp.append(uname! + "          \(score!)\n")
                }
            } else {
                success = 2
            }
        } catch {
            print("Tables might not exist in the database")
            
            success = 3
        }
        
        var string = "Player            Score\n"
        
        for str in temp {
            print(str)
            string = string + str
        }
        print(string)
        leaderboardTextLabel.numberOfLines = 10;
        leaderboardTextLabel.text = string
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
