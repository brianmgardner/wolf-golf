//
//  Player.swift
//  WolfGolf
//
//  Created by Ryan Resma on 7/8/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import Foundation

// Player object will encapsulate each participant in WolfGolf
class Player {
    var name: String?
    var currScore: Int?
    // Player 1, 2, 3, 4
    var playerIndex: Int?
    var isWolfTeam: Bool?
    
    init(n: String, cs: Int, pi: Int, isWolf: Bool) {
        self.name = n
        self.currScore = cs
        self.playerIndex = pi
        self.isWolfTeam = isWolf
    }
}
