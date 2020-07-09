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
    
    var nextRoundLock: Bool = false
    var chooseTeamLock: Bool = false
    var teamPicked: Bool = false
    var nextRoundPressed: Bool = false
    var chooseWinnerLock: Bool = false
    var winnerChosen: Bool = false

    
    @IBOutlet weak var curHoleLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var teammateLabel: UILabel!
    @IBOutlet weak var yesTeamButton: UIButton!
    @IBOutlet weak var noTeamButton: UIButton!
    
    @IBOutlet weak var winnerTextLabel: UILabel!
    
    @IBOutlet weak var winnerSeg: UISegmentedControl!
    
    
    let buttonQueue = DispatchQueue(label: "myQueue", qos: .default)
    
    var curWolf: Player!
    var curTeammate: Player!
    var curOnTee: Player!
    var wolfWon: Bool!
    
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
        
        playGame(numRounds: numRounds)
        
    }
    
    // randomly fill queue in proper tee-off ordering
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
            
            // thought: would round -= 1 work as an "undo round" button/feature
            for round in 1...numRounds {
                print("round #: \(round)")
                
                self.curWolf = self.playerQueue!.tail!
                
                DispatchQueue.main.sync {
                    // update hole/wolf
                    self.curHoleLabel.text = """
                    Current Hole: \(round)
                    Wolf: \(self.curWolf.name!)
                    """
                    
                    // hide winner stuff until last tee of round
                    self.winnerTextLabel.isHidden = false
                    self.winnerSeg.isHidden = false
                }
                
                // determine players order and prompt them to tee off
                
                // loop through other 3 players before wolf goes
                //self.buttonQueue.async {
                self.teammateLabel.isHidden = false
                self.noTeamButton.setTitle("NO", for: .normal)
                self.noTeamButton.backgroundColor = UIColor.red
                for tee in 1...3 {
                    
                    self.curOnTee = self.playerQueue!.dequeue()!
                    self.playerQueue!.enqueue(self.curOnTee)
                    
                    DispatchQueue.main.sync {
                        self.promptLabel.text = "\(self.curOnTee.name!) Up to Tee!"
                        self.teammateLabel.text = """
                            Choose \(self.curOnTee.name!)
                                    as teammate?"
                            """
                        self.teammateLabel.textAlignment = .center

                    }
                    
                    // If down to third tee, its either team up or go wolf
                    if (tee == 3) {
                        DispatchQueue.main.sync {
                            self.noTeamButton.backgroundColor = UIColor.blue
                            self.noTeamButton.setTitle("WOLF", for: .normal)
                            // TODO: only show winner stuff at the end of tees
                            self.winnerTextLabel.isHidden = false
                            self.winnerTextLabel.text = "Hole \(round)'s Winner:"
                            self.winnerSeg.isHidden = false
                        }
                    }
                    
                    self.teamPicked = false
                    self.chooseTeamLock = true
                    // wait for 'yes/no' to be pressed
                    while (!self.teamPicked) {
                        usleep(400000)
                        print(".")
                    }
                    
                    self.chooseTeamLock = false
                    
                } // -- end current round loop --
                //  }
                
                
                
                // tally up the points
                
                
                self.nextRoundPressed = false
                self.nextRoundLock = true
                // wait for 'next round' button to be pressed
                while (!self.nextRoundPressed) {
                    usleep(400000)
                    print("-")
                }
                self.nextRoundLock = false
                
            } // -- end game loop
            
            // save stats here
            
        }
    }
    
    @IBAction func yesClicked(_ sender: Any) {
        if (chooseTeamLock) {
            curTeammate = curOnTee
            teammateLabel.isHidden = true
            print("\(curTeammate!) picked as teammate")
            teamPicked = true
        } else {
            print("can't do that right now.")
        }
    }
    
    
    @IBAction func noClicked(_ sender: Any) {
        if (chooseTeamLock) {
            teamPicked = true
            print("denied as teammate")
        } else {
            print("can't do that right now.")
        }
    }
    
    @IBAction func nextRoundClicked(_ sender: Any) {
        if (nextRoundLock) {
            print("next round")
            nextRoundPressed = true
        } else {
            print("can't do that right now.")
        }
    }
    

    @IBAction func winnerSegChosen(_ sender: Any) {
        if (chooseWinnerLock) {
            switch winnerSeg.selectedSegmentIndex {
            case 0:
                wolfWon = true
                print("\(curWolf!) wins the round.")
            case 1:
                wolfWon = false
                print("\(curWolf!) loses the round")
            default:
                print("ERROR")
            }
        } else {
            print("can't do that right now.")
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
