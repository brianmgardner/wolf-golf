//
//  NewGameViewController.swift
//  WolfGolf
//
//  Created by Brian Gardner on 7/7/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController {
    
    // TODO: edit addPlayerLabel when all players added
    @IBOutlet weak var addPlayerLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var player1TextField: UITextField!
    @IBOutlet weak var player2TextField: UITextField!
    @IBOutlet weak var player3TextField: UITextField!
    @IBOutlet weak var player4TextField: UITextField!
    @IBOutlet weak var addPlayer1Button: UIButton!
    @IBOutlet weak var addPlayer2Button: UIButton!
    @IBOutlet weak var addPlayer3Button: UIButton!
    @IBOutlet weak var addPlayer4Button: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    
    var delegate: UIViewController!
    
    var player1 : Player!
    var player2 : Player!
    var player3 : Player!
    var player4 : Player!
    
    var playerNamesList: [String] = []
    //TODO: change to an array of object type Player
    var playerAr: [Player] = [Player(n: "", cs: 0, pi: -1),
                              Player(n: "", cs: 0, pi: -1),
                              Player(n: "", cs: 0, pi: -1),
                              Player(n: "", cs: 0, pi: -1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // trying to make button a circle, not sure if this works at all
        startGameButton.layer.cornerRadius = 50
        promptLabel.numberOfLines = 0
    }
    
    // a helper method to reduce redundancy
    func addPlayer(playerNum: Int, name: String, field: UITextField) {
        let trimmedName = name.replacingOccurrences(of: " ", with: "")
        if (trimmedName.count > 0 && (!playerNamesList.contains(trimmedName))) {
            // -1 for 0-based indexing
            self.playerAr[playerNum - 1] = Player(n: trimmedName, cs: 0, pi: playerNum)
            playerNamesList.insert(trimmedName, at: playerNamesList.endIndex)
            field.backgroundColor = UIColor.gray
            promptLabel.isHidden = true
        } else {
            promptLabel.isHidden = false
            //TODO: fix case if double click add
            if (playerNamesList.contains(trimmedName)) {
                if (playerAr[playerNum - 1].name == trimmedName) {
                    promptLabel.text = """
                    Don't click the button again if
                    you didn't even change the name.
                            >:-(
                    """
                } else {
                    field.backgroundColor = UIColor.red
                    promptLabel.text = """
                    Someone is already using that name.
                    Make it different.
                    """
                }
            } else {
                field.backgroundColor = UIColor.red
                promptLabel.text = "Invalid Input. Try Again."
            }
        }
    }
    
    
    @IBAction func player1Added(_ sender: Any) {
        let str: String = player1TextField.text!
        addPlayer(playerNum: 1, name: str, field: player1TextField)
    }
    

    @IBAction func player2Added(_ sender: Any) {
        let str: String = player2TextField.text!
        addPlayer(playerNum: 2, name: str, field: player2TextField)
    }
    
    
    @IBAction func player3Added(_ sender: Any) {
        let str: String = player3TextField.text!
        addPlayer(playerNum: 3, name: str, field: player3TextField)
    }
    
    
    @IBAction func player4Added(_ sender: Any) {
        let str: String = player4TextField.text!
        addPlayer(playerNum: 4, name: str, field: player4TextField)
    }
    
    
    func playerNamesAreValid() -> Bool {
        return playerAr[0].name!.count > 0 && playerAr[1].name!.count > 0 &&
            playerAr[2].name!.count > 0 && playerAr[3].name!.count > 0
    }
    
    
    @IBAction func startGameClicked(_ sender: Any) {
        if (playerNamesAreValid()) {
            performSegue(withIdentifier: "startGameSegue", sender: self)
        } else {
            promptLabel.isHidden = false
            promptLabel.text = """
            Player Names Not Properly Set Up.
            Cannot Start Game Yet.
            """
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGameSegue",
            let nextVC = segue.destination as? GameViewController {
            nextVC.delegate = self
            nextVC.player1 = playerAr[0]
            nextVC.player2 = playerAr[1]
            nextVC.player3 = playerAr[2]
            nextVC.player4 = playerAr[3]
        }
    }
    
    
    // code to enable tapping on the background to remove software keyboard
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

}
