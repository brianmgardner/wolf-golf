//
//  PlayerQueue.swift
//  WolfGolf
//
//  Created by Brian Gardner on 7/8/20.
//  Copyright © 2020 gardner. All rights reserved.
//
// credit to:
// https://benoitpasquier.com/data-structure-implement-queue-swift/

import Foundation

class PlayerQueue<T> {
    private var elements: [T] = []
    
    func enqueue(_ value: T) {
        elements.append(value)
    }
    
    func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }
    
    var head: T? {
        return elements.first
    }
    
    var tail: T? {
        return elements.last
    }
}
