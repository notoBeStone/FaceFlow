//
//  Dice.swift
//  DangJi
//
//  Created by Martin on 2022/1/20.
//  Copyright © 2022 Glority. All rights reserved.
//

import UIKit

public class Dice {
    public static func dice(_ max: Int) -> Int {
        Int(arc4random()) % max
    }
    
    //<= number
    public static func gambler(_ number: Int) -> Bool {
        let d = dice(100)
        return d < number
    }
}
