//
//  Round.swift
//  WolfGolf
//
//  Created by Brian Gardner on 7/9/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import Foundation

class Round {
    var holeNum: Int?
    var wolfName: String?
    var teammateName: String?
    var winnerName: String?
    
    init(num: Int, wolf: String, team: String, winner: String) {
        self.holeNum = num
        self.wolfName = wolf
        self.teammateName = team
        self.winnerName = winner
    }
}
