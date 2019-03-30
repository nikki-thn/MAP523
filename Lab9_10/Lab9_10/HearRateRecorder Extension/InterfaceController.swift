//
//  InterfaceController.swift
//  HearRateRecorder Extension
//
//  Created by Nikki Truong on 2019-03-29.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

/*
 https://www.raywenderlich.com/288-watchos-4-tutorial-part-2-tables
 */

import WatchKit
import Foundation
import CoreData
import UIKit

var sessions = [Session]()

class InterfaceController: WKInterfaceController {
    
    let fileName = "test"
    var heartRates = [Int]()
    var check = 0
    
    @IBOutlet weak var label: WKInterfaceLabel!
    
    @IBAction func longPressGesture(_ sender: Any) {
        historyBtn.setHidden(false)
    }
    
    @IBOutlet weak var historyBtn: WKInterfaceButton!
    
    @IBAction func recordBtn() {
        
        var newSession = Session()
        
        for _ in 0..<5 {
            heartRates.append(Int.random(in: 80..<110))
        }
        
        newSession.max = heartRates.max() ?? 110
        newSession.min = heartRates.min() ?? 80
        newSession.avg = Double(heartRates.reduce(0, +)) / Double(heartRates.count)
        
        sessions.append(newSession)
        label.setText("new session created")
        label.setHidden(false)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        readFromFile()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        label.setHidden(true)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        historyBtn.setHidden(true)
        saveToFile()
    }
    
    func saveToFile(){
        
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)

        // If the directory was found, we write a file to it and read it back
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            print(fileURL)

            let jsonEncoder = JSONEncoder()
            var jsonString = ""
            
            do {
                for session in sessions {

                    let jsonData = try jsonEncoder.encode(session)
                    print(jsonData)
                    jsonString += String(data: jsonData, encoding: .utf8) ?? ""
                    jsonString += "|"
                }

                do {
                    try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("Write to the file: \(jsonString)")
                } catch {
                    print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
                }

            } catch {
                print("Error encoding")
            }

            print(jsonString)
        }
    }
    
    func readFromFile() {
        
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        
        // If the directory was found, we write a file to it and read it back
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            print(fileURL)

        var inString = ""
        do {
            inString = try String(contentsOf: fileURL)
            print("Read from the file: \(inString)")
        } catch {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        let temp = inString.components(separatedBy: "|")
        
        for str in temp {
            if let jsonData = str.data(using: .utf8) {
                let jsonDecoder = JSONDecoder()
                do {
                    let ses = try jsonDecoder.decode(Session.self, from: jsonData)
                    sessions.append(ses)
                    print(ses.max)
                    print(ses.min)
                    print(ses.avg)
                } catch {
                    
                }
            } else {
                print("error")
            }
        }
        }
    }
}
