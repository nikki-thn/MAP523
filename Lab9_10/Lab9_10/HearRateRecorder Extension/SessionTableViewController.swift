//
//  SessionTableViewController.swift
//  HearRateRecorder Extension
//
//  Created by Nikki Truong on 2019-03-29.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import UIKit
import WatchKit

class SessionTableViewController: WKInterfaceController {

    @IBOutlet weak var sessionTable: WKInterfaceTable!
    
    @IBOutlet weak var clearAllBtn: WKInterfaceButton!
    
    @IBAction func clearAllSessions() {
        sessions.removeAll()
        loadTableData()
    }
    
    @IBAction func longGesture(_ sender: Any) {
       clearAllBtn.setHidden(false)
 
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadTableData()
    }
    
    private func loadTableData() {
        
        sessionTable.setNumberOfRows(sessions.count, withRowType: "SessionRowController")
        
        for index in 0..<sessionTable.numberOfRows {
        
            let controller = sessionTable.rowController(at: index) as? SessionRowController
        
            controller?.maxLabel!.setText("\(sessions[index].max) |")
            controller?.maxLabel!.setTextColor(UIColor.red)
            controller?.minLabel!.setText("\(sessions[index].min) |")
            controller?.minLabel!.setTextColor(UIColor.green)
            controller?.avgLabel!.setText("\(sessions[index].avg)")
            controller?.avgLabel!.setTextColor(UIColor.yellow)
        }
    
    }
}


