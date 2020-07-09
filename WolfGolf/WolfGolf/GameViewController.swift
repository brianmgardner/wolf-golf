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
    var yesPicked: Bool = false
    var noPicked: Bool = false
    var isFinalTee: Bool = false
    var nextRoundPressed: Bool = false
    var chooseWinnerLock: Bool = false
    var winnerChosen: Bool = false
    var roundTied: Bool = false
    
    @IBOutlet weak var player1Score: UILabel!
    @IBOutlet weak var player2Score: UILabel!
    @IBOutlet weak var player3Score: UILabel!
    @IBOutlet weak var player4Score: UILabel!
    
    

    
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
        
        print("p1: \(player1.name!)")
        print("p2: \(player2.name!)")
        print("p3: \(player3.name!)")
        print("p4: \(player4.name!)")
        
        player1Score.text = "\(player1.name!)'s score: \(player1.currScore!)"
        player2Score.text = "\(player2.name!)'s score: \(player2.currScore!)"
        player3Score.text = "\(player3.name!)'s score: \(player3.currScore!)"
        player4Score.text = "\(player4.name!)'s score: \(player4.currScore!)"
        
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
                    self.winnerTextLabel.isHidden = true
                    self.winnerSeg.isHidden = true
                    // show teammate stuff until wolf chooses
                    self.yesTeamButton.isHidden = false
                    self.noTeamButton.isHidden = false
                    self.teammateLabel.isHidden = false
                    // reset in case WOLF selected
                    self.noTeamButton.setTitle("NO", for: .normal)
                    self.noTeamButton.backgroundColor = UIColor.red
                }
                self.isFinalTee = false
                
                // loop through other 3 players before wolf goes
                for tee in 1...3 {
                    
                    self.curOnTee = self.playerQueue!.dequeue()!
                    self.playerQueue!.enqueue(self.curOnTee)
                    
                    DispatchQueue.main.sync {
                        self.promptLabel.text = "\(self.curOnTee.name!) Up to Tee!"
                        self.teammateLabel.text = """
                            Choose \(self.curOnTee.name!)
                                    as teammate?
                            """
                        self.teammateLabel.textAlignment = .center

                    }
                    
                    // If down to third tee, its either team up or go wolf
                    if (tee == 3) {
                        DispatchQueue.main.sync {
                            self.noTeamButton.backgroundColor = UIColor.blue
                            self.noTeamButton.setTitle("WOLF", for: .normal)
                            
                            
                            self.isFinalTee = true
                        }
                    }
                    
                    self.teamPicked = false
                    self.chooseTeamLock = true
                    // wait for 'yes/no' to be pressed
                    while (!self.yesPicked && !self.noPicked) {
                        usleep(400000)
                        print(".")
                    }
                    
                    
                    // once a teammate is chosen, skip to decide winner
                    if (self.teamPicked) {
                        //  maybe do other stuff here too?
                        DispatchQueue.main.sync {
                            // only show winner stuff at the end of tees
                            self.winnerTextLabel.isHidden = false
                            self.winnerTextLabel.text = "Hole \(round)'s Winner:"
                            self.winnerSeg.isHidden = false
                        }
                        break
                    }
                    
                } // -- end tee loop --
                // LEFT OFF RIGHT HERE!
                //      - add vars to Player class for wolf/other
                //      - here, loop through a PlayerList and check ^ vars
                //      - tally up appropriate points
                
                // tally up the points
                if (self.roundTied) { // points worth 2x if prev round tied
                    
                }
                
                self.player1Score.text = "\(self.player1.name!)'s score: \(self.player1.currScore!)"
                self.player2Score.text = "\(self.player2.name!)'s score: \(self.player2.currScore!)"
                self.player3Score.text = "\(self.player3.name!)'s score: \(self.player3.currScore!)"
                self.player4Score.text = "\(self.player4.name!)'s score: \(self.player4.currScore!)"
                
                
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
            yesTeamButton.isHidden = true
            noTeamButton.isHidden = true
            print("\(curTeammate!) picked as teammate")
            yesPicked = true
        } else {
            print("can't do that right now.")
        }
    }
    
    
    @IBAction func noClicked(_ sender: Any) {
        if (chooseTeamLock) {
            // player if going wolf, make teamPicked == true to exit tee loop
            if (isFinalTee) {
                teamPicked = true
            }
            noPicked = true
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
            case 0: // WOLF WIN
                wolfWon = true
                print("\(curWolf!) wins the round.")
            case 1: // WOLF LOSE
                wolfWon = false
                print("\(curWolf!) loses the round")
            case 2: // TIE
                wolfWon = false
                roundTied = true
            default:
                print("ERROR")
            }
        } else {
            print("can't do that right now.")
        }
        chooseWinnerLock = false
        
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
