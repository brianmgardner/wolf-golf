//
//  RecordsViewController.swift
//  WolfGolf
//
//  Created by Ryan Resma on 7/7/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit

protocol RecordAdder {
    // MARK: need a game object
    func addRecord(game: Game)
}

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecordAdder {
    
    let tableCellID = "RecordTableCellIdentifier"
    
    var delegate: UIViewController!
    
    @IBOutlet weak var recordsTableView: UITableView!
    
    var recordList: [Game] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellID, for: indexPath) as! RecordTableViewCell
        let currRecord = self.recordList[indexPath.row]
        // modify the current attributes of the cell's UI as necessary
        cell.cellImageView.image = currRecord.image
        cell.cellGameWinnerLabel.text = "Game Winner: \(currRecord.winner!)"
        cell.cellDateLabel.text = "Date: \(currRecord.date!)"
        
        return cell
    }
    
    // handle an alert/modal with all of the game's data
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currRecord = self.recordList[indexPath.row]
        let gameTitle = "\(currRecord.winner!) won the game!"
        let gameMessage = "Date: \(currRecord.date!) \nHigh score: \(currRecord.highScore!) \n\n\(currRecord.description!)"
        let controller = UIAlertController(title: gameTitle,
                                           message: gameMessage, preferredStyle: .alert)
        // thin crust option
        controller.addAction(UIAlertAction(title: "GG \(currRecord.winner!)", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    // remove game
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove the current timer from our list and delete the UI tableViewCell
            self.recordList.remove(at: indexPath.row)
            recordsTableView.deleteRows(at: [indexPath], with: .fade)
        }
        // MARK: commit deletion to core data
    }

    
    // protocol method to change the current game list
    func addRecord(game: Game) {
        self.recordList.append(game)
        self.recordsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordsTableView.delegate = self
        self.recordsTableView.dataSource = self
    }
    
}
