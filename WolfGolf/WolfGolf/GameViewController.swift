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
    
    // TOOD: adding 4 players is redundant when you also bring in the list
    var player1 : Player!
    var player2 : Player!
    var player3 : Player!
    var player4 : Player!
    
    var playersList : [Player]!
    
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
    var prevRoundTied: Bool = false
    var isLoneWolf: Bool = false
    var curRoundTied: Bool = false
    
    
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
                self.curWolf.isWolfTeam = true
                self.winnerChosen = false
                self.yesPicked = false
                self.noPicked = false
                
                
                DispatchQueue.main.sync {
                    // update hole/wolf
                    
                    self.curHoleLabel.text = """
                    Current Hole: \(round)
                    Wolf: \(self.curWolf.name!)
                    """
                    

                    
                    self.winnerSeg.selectedSegmentIndex = UISegmentedControl.noSegment
                    self.curWolf.isWolfTeam = true
                    
                    self.noTeamButton.setTitle("NO", for: .normal)
                    self.noTeamButton.backgroundColor = UIColor.red
                    
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
                //self.buttonQueue.async {
                    
                    for tee in 1...3 {
                        
                        self.curOnTee = self.playerQueue!.dequeue()!
                        self.playerQueue!.enqueue(self.curOnTee)
                        print("\(self.curOnTee.name!) is on the tee")
                        
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
                        self.noPicked = false
                        // wait for 'yes/no' to be pressed
                        while (!self.yesPicked && !self.noPicked) {
                            usleep(400000)
                            print(".")
                        }
                        
                        
                        // once a teammate is chosen, skip to decide winner
                        if (self.teamPicked) {
                            print("showing winner stuff")
                            //  maybe do other stuff here too?
                            DispatchQueue.main.sync {
                                // show added teammate
                                if (self.curTeammate != nil) {
                                    self.curHoleLabel.text = """
                                    Current Hole: \(round)
                                    Wolf: \(self.curWolf.name!)
                                    Teammate: \(self.curTeammate.name!)
                                    """
                                }
                                // only show winner stuff at the end of tees
                                self.winnerTextLabel.isHidden = false
                                self.winnerTextLabel.text = "Select Hole \(round)'s Winner(s):"
                                self.winnerSeg.isHidden = false
                            }
                            print("BREAKING from tee loop")
                            break
                        }
                        
                    } // -- end tee loop --
                //}
                
                
                // choose winner
                self.chooseWinnerLock = true
                // wait for winner of round to be chosen
                while (!self.winnerChosen) {
                    usleep(300000)
                    print(",")
                }
                self.chooseWinnerLock = false
                
                // LEFT OFF RIGHT HERE!
                //      - add vars to Player class for wolf/other
                //      - here, loop through a PlayerList and check ^ vars
                //      - tally up appropriate points
                var winPoints: Int
                if (self.isLoneWolf) {
                    if (self.wolfWon) {
                        winPoints = 4
                    } else {
                        winPoints = 1
                    }
                } else {
                    winPoints = 2
                }
                
                // add points to winPoints to winners
                
                for player in self.playersList {
                    
                    if ((self.wolfWon && player.isWolfTeam!) ||
                        (!self.wolfWon) && !player.isWolfTeam!) {
                        if (!self.curRoundTied) {
                            if (self.prevRoundTied) {
                                print("TIED 2x POINTS")
                                winPoints *= 2
                                self.prevRoundTied = false
                            }
                            player.currScore! += winPoints
                            print("adding points")
                            print("\(player.name!) : isWolfTeam: \(player.isWolfTeam!)")
                            
                        }
                        
                        player.isWolfTeam! = false
                    }
                }
                self.curRoundTied = false
                
                DispatchQueue.main.sync {
                    // Update scoreboard
                    self.player1Score.text = "\(self.player1.name!)'s score: \(self.player1.currScore!)"
                    self.player2Score.text = "\(self.player2.name!)'s score: \(self.player2.currScore!)"
                    self.player3Score.text = "\(self.player3.name!)'s score: \(self.player3.currScore!)"
                    self.player4Score.text = "\(self.player4.name!)'s score: \(self.player4.currScore!)"
                }
                
                
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
            curTeammate.isWolfTeam = true
            print("curT: \(curTeammate.name!)")
            promptLabel.text = "Play Out Round"
            teammateLabel.isHidden = true
            yesTeamButton.isHidden = true
            noTeamButton.isHidden = true
            isLoneWolf = false
            print("\(curTeammate!) picked as teammate")
            yesPicked = true
            teamPicked = true
        } else {
            print("can't do that right now.")
        }
    }
    
    
    @IBAction func noClicked(_ sender: Any) {
        if (chooseTeamLock) {
            // player if going wolf, make teamPicked == true to exit tee loop
            if (isFinalTee) {
                teamPicked = true
                isLoneWolf = true
                promptLabel.text = "Play Out Round"
                teammateLabel.isHidden = true
                yesTeamButton.isHidden = true
                noTeamButton.isHidden = true
                print("\(curWolf!) is LONE WOLF")
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
            // reset curWolf/teammate vars
            if (curTeammate != nil) {
                curTeammate.isWolfTeam = false
            }
            nextRoundPressed = true
            curWolf.isWolfTeam = false
        } else {
            print("can't do that right now.")
        }
    }
    

    @IBAction func winnerSegChosen(_ sender: Any) {
        if (chooseWinnerLock) {
            switch winnerSeg.selectedSegmentIndex {
            case 0: // WOLF WIN
                wolfWon = true
                print("\(curWolf.name!) wins the round.")
            case 1: // WOLF LOSE
                wolfWon = false
                print("\(curWolf.name!) loses the round")
            case 2: // TIE
                wolfWon = false
                prevRoundTied = true
                curRoundTied = true
                print("ITS A TIE!")
            default:
                print("ERROR")
            }
        } else {
            print("can't do that right now.")
        }
        winnerChosen = true
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
