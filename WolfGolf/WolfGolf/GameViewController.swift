//
//  GameViewController.swift
//  WolfGolf
//
//  Created by Brian Gardner on 7/8/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var delegate : UIViewController!
    
    var player1 : Player!
    var player2 : Player!
    var player3 : Player!
    var player4 : Player!
    
    let numRounds: Int? = nil
    var playerQueue: PlayerQueue<Player>?
    
    var chooseTeamLock: Bool = false
    var teamPicked: Bool = false

    
    @IBOutlet weak var curHoleLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var teammateLabel: UILabel!
    @IBOutlet weak var yesTeamButton: UIButton!
    @IBOutlet weak var noTeamButton: UIButton!
    
    let buttonQueue = DispatchQueue(label: "myQueue", qos: .default)
    
    var curTeammate: Player!
    var curOnTee: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let numRounds: Int = appDelegate.isNineHole ? 9 : 18
        
        playerQueue = PlayerQueue<Player>()
        
        print("p1: \(String(describing: player1.name))")
        print("p2: \(String(describing: player2.name))")
        print("p3: \(String(describing: player3.name))")
        print("p4: \(String(describing: player4.name))")
        
        randomlyPickFirst()
        
        playGame(numRounds: 18)
        
    }
    
    func randomlyPickFirst() {
        let rand = Int.random(in: 1...4)
        switch rand {
        case 1:
            playerQueue!.enqueue(player1)
            playerQueue!.enqueue(player2)
            playerQueue!.enqueue(player3)
            playerQueue!.enqueue(player4)
        case 2:
            playerQueue!.enqueue(player2)
            playerQueue!.enqueue(player3)
            playerQueue!.enqueue(player4)
            playerQueue!.enqueue(player1)
        case 3:
            playerQueue!.enqueue(player3)
            playerQueue!.enqueue(player4)
            playerQueue!.enqueue(player1)
            playerQueue!.enqueue(player2)
        case 4:
            playerQueue!.enqueue(player4)
            playerQueue!.enqueue(player1)
            playerQueue!.enqueue(player2)
            playerQueue!.enqueue(player3)
        default:
            print("what'd u do wrong??")
        }
    }
    
    func playGame(numRounds: Int) {
        
        buttonQueue.async {
        for round in 1...numRounds {
            print(round)
            
            let curWolf: Player = self.playerQueue!.tail!
            
            DispatchQueue.main.sync {
                self.curHoleLabel.text = """
                Current Hole: \(round)
                Wolf: \(curWolf.name!)
                """
            }
            
            
            
            // determine players order and prompt them to tee off
            
            // loop through other 3 players before wolf goes
            self.buttonQueue.async {
                for _ in 1...3 {
                    
                    self.curOnTee = self.playerQueue!.dequeue()!
                    self.playerQueue!.enqueue(self.curOnTee)
                    
                    DispatchQueue.main.sync {
                        self.promptLabel.text = "\(self.curOnTee.name!) Up to Tee!"
                        self.teammateLabel.text = "Choose \(self.curOnTee.name!) as teammate"
                    }
                    
                    
                    self.teamPicked = false
                    self.chooseTeamLock = true
                    //buttonQueue.async {
                    while (!self.teamPicked) {
                        usleep(500000)
                        print(".")
                    }
                    //}
                    self.chooseTeamLock = false
                    
                }
            }
            
             }
            
            
            
            // first player swings
            // prompt wolf if they want to team with them
            
            // second player swings
            // prompt wolf if they want to team with them
            
            // third player swings
            // prompt wolf if they want to team with them
            // If wolf declines teaming with partner3, then they are LONE WOLF
            
            // wait for hole to play out
            
            // enter winner of the hole or enter tie
            // if tie, then next hole is 2x points
            
            // tally up and assign points to the players
            // next hole
        }
    }
    
    @IBAction func yesClicked(_ sender: Any) {
        if (chooseTeamLock) {
            curTeammate = curOnTee
            print("\(curTeammate!) picked as teammate")
            teamPicked = true
        }
    }
    
    
    @IBAction func noClicked(_ sender: Any) {
        if (chooseTeamLock) {
            teamPicked = true
        }
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
