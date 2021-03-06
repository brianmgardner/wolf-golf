//
//  GameViewController.swift
//  WolfGolf
//
//  Created by Brian Gardner on 7/8/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class RoundTableViewCell: UITableViewCell {
    @IBOutlet weak var cellHoleLabel: UILabel!
    @IBOutlet weak var cellWolfLabel: UILabel!
    @IBOutlet weak var cellTeamLabel: UILabel!
    @IBOutlet weak var cellWinnerLabel: UILabel!
}

protocol ChangeGameVariation {
    func setGameVariation(isVar1: Bool)
}



class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // In Game Variation 1, Ties double the points of the following round
    var isGameVariation1: Bool {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.isVariation1
        }
    }
    
    var roundsList: [Round] = []
    
    var delegate : UIViewController!
    
    var player1: Player!
    var player2: Player!
    var player3: Player!
    var player4: Player!
    
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
    
    var gameImage: UIImage? = nil
    
    @IBOutlet weak var player1Score: UILabel!
    @IBOutlet weak var player2Score: UILabel!
    @IBOutlet weak var player3Score: UILabel!
    @IBOutlet weak var player4Score: UILabel!
    @IBOutlet weak var roundsTableView: UITableView!
    @IBOutlet weak var curHoleLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var teammateLabel: UILabel!
    @IBOutlet weak var yesTeamButton: UIButton!
    @IBOutlet weak var noTeamButton: UIButton!
    @IBOutlet weak var winnerTextLabel: UILabel!
    @IBOutlet weak var winnerSeg: UISegmentedControl!
    @IBOutlet weak var nextButton: UIButton!
    
    let buttonQueue = DispatchQueue(label: "myQueue", qos: .default)
    
    var curWolf: Player!
    var curTeammate: Player!
    var curOnTee: Player!
    var wolfWon: Bool!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roundsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = roundsTableView.dequeueReusableCell(withIdentifier: "roundCellID", for: indexPath) as! RoundTableViewCell
        let row = indexPath.row
        let curRound = roundsList[row]
        
        cell.cellHoleLabel.text = "HOLE: \(curRound.holeNum!)"
        cell.cellWolfLabel.text = "Wolf: \(curRound.wolfName!)"
        cell.cellTeamLabel.text = "\(curRound.teammateName!)"
        cell.cellWinnerLabel.text = "Winner: \(curRound.winnerName!)"
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let black = CGColor(srgbRed: 0x00, green: 0x00, blue: 0x00, alpha: 1.0)
        yesTeamButton.layer.cornerRadius = 10
        yesTeamButton.layer.borderWidth = 2
        yesTeamButton.layer.borderColor = black
        noTeamButton.layer.cornerRadius = 10
        noTeamButton.layer.borderWidth = 2
        noTeamButton.layer.borderColor = black
        nextButton.layer.cornerRadius = 10
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = black
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let numRounds: Int = appDelegate.isNineHole ? 9 : 18
        
        playerQueue = PlayerQueue<Player>()
        
        // init roundsTableView
        roundsTableView.delegate = self
        roundsTableView.dataSource = self
        
        updateScoreboardUI()
        
        randomlyPickFirst()
        
        playGame(numRounds: numRounds) // TODO: change ack to numRounds
        
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
            print("ERROR setting up queue")
        }
    }
    
    
    // reset the proper booleans at the beginning of each round
    func updateNewRoundBools() {
        self.curWolf = self.playerQueue!.tail!
        self.curTeammate = nil
        print("curWOLF: \(self.curWolf.name!)")
        self.curWolf.isWolfTeam = true
        self.isFinalTee = false
        self.winnerChosen = false
        self.yesPicked = false
        self.noPicked = false
    }
    
    
    // reset the proper UI at the beginning of each round
    func updateNewRoundUI(round: Int) {
        DispatchQueue.main.sync {
            // update hole/wolf
            self.curHoleLabel.text = """
            Current Hole: \(round)
            Wolf: \(self.curWolf.name!)
            """
            self.winnerSeg.selectedSegmentIndex = UISegmentedControl.noSegment
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
    }
    
    
    // update the UI to show the current player on tee
    func updateNewTeeUI() {
        DispatchQueue.main.sync {
            self.promptLabel.text = "\(self.curOnTee.name!) Up to Tee!"
            self.teammateLabel.text = """
            Choose \(self.curOnTee.name!)
            as teammate?
            """
            self.teammateLabel.textAlignment = .center
        }
    }
    
    
    // move the first player in queue to the back of the queue
    func rotateQueue() {
        self.curOnTee = self.playerQueue!.dequeue()!
        self.playerQueue!.enqueue(self.curOnTee)
    }
    
    
    // sleep until yesClicked() or noClicked()
    func waitForUserChooseTeam() {
        self.teamPicked = false
        self.chooseTeamLock = true
        self.noPicked = false
        self.yesPicked = false
        // wait for 'yes/no' to be pressed
        while (!self.yesPicked && !self.noPicked) {
            usleep(300000)
            //print(".")
        }
    }
    
    
    // sleep until winnerSegChosen()
    func waitForUserChooseWinner() {
        self.chooseWinnerLock = true
        // wait for winner of round to be chosen by user
        while (!self.winnerChosen) {
            usleep(300000)
            //print(",")
        }
        self.chooseWinnerLock = false
    }
    
    
    // check if wolf/team win/lose/tie to assign correct points
    func getWinPoints() -> Int {
        if (self.isLoneWolf) {
            if (self.wolfWon) {
                return  4 // lone wolf won
            } else {
                return 1 // lone wolf lost
            }
        } else { // teams
            if (self.wolfWon) {
                return 2 // wolf team won
            } else{
                return 3 // other team beat wolf team
            }
        }
    }
    
    
    // assign winPoints to the correct players
    func addWinPoints(val: Int) {
        for player in self.playersList {
            var winPoints = val
            if ((self.wolfWon && player.isWolfTeam!) ||
                (!self.wolfWon) && !player.isWolfTeam!) {
                if (!self.curRoundTied) {
                    // ties make the next round worth double
                    if (self.prevRoundTied) {
                        if (isGameVariation1) {
                            winPoints *= 2
                        }
                        self.prevRoundTied = false
                    }
                    player.currScore! += winPoints
                }
                player.isWolfTeam! = false
            }
        }
        self.curRoundTied = false
    }
    
    
    // update the players' current point labels to reflect score changes
    func updateScoreboardUI() {
        self.player1Score.text = "\(self.player1.name!)'s score: \(self.player1.currScore!)"
        self.player2Score.text = "\(self.player2.name!)'s score: \(self.player2.currScore!)"
        self.player3Score.text = "\(self.player3.name!)'s score: \(self.player3.currScore!)"
        self.player4Score.text = "\(self.player4.name!)'s score: \(self.player4.currScore!)"
    }
    
    
    // When a teammate is picked early, finish rotating the queue properly for the next round
    func finishTees(round: Int, tee: Int) {
        DispatchQueue.main.sync {
            // show added teammate
            if (self.curTeammate != nil) {
                self.curHoleLabel.text = """
                Current Hole: \(round)
                Wolf: \(self.curWolf.name!)
                Teammate: \(self.curTeammate.name!)
                """
            } else {
                self.curHoleLabel.text = """
                Current Hole: \(round)
                Wolf: \(self.curWolf.name!)
                LONE WOLF
                """
            }
            // only show winner stuff at the end of tees
            self.winnerTextLabel.isHidden = false
            self.winnerTextLabel.text = "Select Hole \(round)'s Winner(s):"
            self.winnerSeg.isHidden = false
            
            var t = tee
            while (t <= 4) {
                self.rotateQueue()
                t += 1
            }
        }
    }
    
    
    // change red 'NO' button to blue 'WOLF' button
    func convertNoToWolf() {
        DispatchQueue.main.sync {
            self.noTeamButton.backgroundColor = UIColor.blue
            self.noTeamButton.setTitle("WOLF", for: .normal)
            self.isFinalTee = true
        }
    }
    
    
    // sleep until winnerSegChosen()
    func waitForUserPressNext() {
        self.nextRoundPressed = false
        self.nextRoundLock = true
        // wait for 'next round' button to be pressed
        while (!self.nextRoundPressed) {
            usleep(300000)
            //print("-")
        }
        self.nextRoundLock = false
    }
    
    
    // add the stats for the current round as arow to roundsTableView
    func addRoundResultsToTable(round: Int) {
        // add round to roundsViewTable
        let teammateName: String = !self.isLoneWolf ? "Team: \(self.curTeammate.name!)" : "LONE WOLF"
        var roundWinner: String = self.wolfWon ? "Wolf" : "Others"
        if (self.prevRoundTied) {
            roundWinner = "TIE"
        }
        let curRound: Round = Round(num: round, wolf: self.curWolf.name!,
                                    team: teammateName, winner: roundWinner)
        DispatchQueue.main.sync {
            self.roundsList.insert(curRound, at: self.roundsList.endIndex)
            self.roundsTableView.reloadData()
        }
    }
    
    
    // the main functionality for playing a game of Wolf Golf
    func playGame(numRounds: Int) {
        buttonQueue.async {
            // loop through each round/hole of golf. either 9 or 18 holes
            for round in 1...numRounds {
                self.updateNewRoundBools()
                self.updateNewRoundUI(round: round)
                // loop through other 3 players before wolf goes
                for tee in 1...3 {
                    // move current player from front to back of queue
                    self.rotateQueue()
                    // show current player
                    self.updateNewTeeUI()
                    // If down to third tee, its either team up or go wolf
                    if (tee == 3) {
                        // change the red 'NO' button to blue 'WOLF' button on final tee
                        self.convertNoToWolf()
                    }
                    // user needs to click yes/no to proceed
                    self.waitForUserChooseTeam()
                    // once a teammate is chosen, skip to decide winner
                    if (self.teamPicked) {
                        self.finishTees(round: round, tee: tee)
                        break   // break from tee after team is selected
                    }
                } // -- end tee loop --
                // user needs to select a winner to proceed
                self.waitForUserChooseWinner()
                // add winPoints to winners
                self.addWinPoints(val: self.getWinPoints())
                // show newly changed scores
                DispatchQueue.main.sync {
                    self.updateScoreboardUI()
                }
                // user needs to select 'Next' button to proceed
                self.waitForUserPressNext()
                // update roundsViewTable to show the stats from this round
                self.addRoundResultsToTable(round: round)
                // -- end round --
            } // -- end game loop --
            // tell user that game ended
            // show who won
            
            // save stats here
            DispatchQueue.main.sync {
                self.promptLabel.text = "Done! Take A Pic!"
                self.takePicturePrompt()
            }
        }
    }
    
    
    // returns true once the user clicks 'YES'
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
            print("\(curTeammate.name!) picked as teammate")
            yesPicked = true
            teamPicked = true
        } else {
            print("can't do that right now.")
        }
    }
    
    
    // returns true once the user clicks 'NO'
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
    
    
    // returns true once the user clicks 'next'
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
    
    
    // return true once the user selects a winner for the round
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
    
    func displayGameStats() {
        let winner: String! = self.gameWinner.name!
        let highScore: Int! = self.gameWinner.currScore!
        
        // date to string
        let date: Date = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeStamp = dateFormatter.string(from: date)
        
        // currImage: UIImage?, currHighScore: Int?, currDescription: String?, currWinner: String?, currDate: String?
        let currImage: UIImage = self.gameImage ?? UIImage()
        let currGame = Game(i: currImage, hs: highScore, w: winner, da: timeStamp)
        
        let controller = UIAlertController(title: "Game Finished!", message: "\(self.gameWinner.name!) won the game with a score of \(self.gameWinner.currScore!)! See game history in Records Tab at main menu.", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {action in self.storeGame(g: currGame)}))
        present(controller, animated: true, completion: nil)
    }
    
    var gameWinner: Player {
        get {
            var currWinner: Player = self.player1
            var currHighScore: Int = self.player1.currScore!
            if self.player2.currScore! > currHighScore {
                currWinner = self.player2
                currHighScore = self.player2.currScore!
            }
            if self.player3.currScore! > currHighScore {
                currWinner = self.player3
                currHighScore = self.player3.currScore!
            }
            if self.player4.currScore! > currHighScore {
                currWinner = self.player4
                currHighScore = self.player4.currScore!
            }
            return currWinner
        }
    }
    
    func storeGame(g: Game) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // setting attribute values for the NSEntityObject
        let game = NSEntityDescription.insertNewObject(forEntityName: "UserGame", into: context)
        game.setValue(g.date!, forKey: "date")
        game.setValue(g.highScore!, forKey: "highScore")
        game.setValue(g.winner!, forKey: "winner")
        let imageData: Data? = g.image?.pngData()
        game.setValue(imageData, forKey: "image")
        // try to save context to core data
        do {
            try context.save()
            print("Context saved correctly!")
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        // make the change to the table data
        appDelegate.recordList.append(g)
    }
    
    // helper to access iOS device's native system camera
    func takePicturePrompt() {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.allowsEditing = true
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found!")
            return
        }
        print("image was taken and saved correctly")
        self.gameImage = image
        self.displayGameStats()
    }

}
