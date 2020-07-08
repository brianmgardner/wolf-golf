//
//  Game.swift
//  WolfGolf
//
//  Created by Ryan Resma on 7/7/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import Foundation
import UIKit

class Game {
    var image: UIImage?
    var highScore: Int?
    var description: String?
    // change to Player object
    var winner: String?
    var date: String?
    
    init(i: UIImage, hs: Int, de: String, w: String, da: String) {
        self.image = i
        self.highScore = hs
        self.description = de
        self.winner = w
        self.date = da
    }
}
