//
//  TableViewController.swift
//  Lab9_10
//
//  Created by Nikki Truong on 2019-03-29.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import WatchKit
import Foundation

struct Session: Codable {
    
    var max: Int
    var min: Int
    var avg: Double
    
    init() {
        max = 0;
        min = 0;
        avg = 0;
    }
}
