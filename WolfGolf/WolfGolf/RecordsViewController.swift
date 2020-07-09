//
//  RecordsViewController.swift
//  WolfGolf
//
//  Created by Ryan Resma on 7/7/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol RecordAdder {
    // MARK: need a game object
    func addRecord(game: Game)
}

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecordAdder {
    
    let tableCellID = "RecordCellIdentfier"
    
    var delegate: UIViewController!
    
    @IBOutlet weak var recordsTableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.recordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellID, for: indexPath) as! RecordTableViewCell
        let currRecord = appDelegate.recordList[indexPath.row]
        // modify the current attributes of the cell's UI as necessary
        cell.cellImageView.image = currRecord.image
        cell.cellGameWinnerLabel.text = "Game Winner: \(currRecord.winner!)"
        cell.cellDateLabel.text = "Date: \(currRecord.date!)"
        
        return cell
    }
    
    // handle an alert/modal with all of the game's data
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currRecord = appDelegate.recordList[indexPath.row]
        let gameTitle = "\(currRecord.winner!) won the game!"
        let numHoles = appDelegate.isNineHole ? 9 : 18
        let gameMessage = "Date: \(currRecord.date!) \nHigh score: \(currRecord.highScore!) \n\nNumber of Holes played: \(numHoles)"
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
            appDelegate.recordList.remove(at: indexPath.row)
            recordsTableView.deleteRows(at: [indexPath], with: .fade)
        }
        // MARK: commit deletion to core data
    }
    
    
    // protocol method to change the current game list
    func addRecord(game: Game) {
        appDelegate.recordList.append(game)
        self.recordsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordsTableView.delegate = self
        self.recordsTableView.dataSource = self
        let records = self.retrieveRecords()
        for game in records {
            // MARK: saving an image errors here
            // let image = UIImage(data: game.value(forKey: "image") as! Data), change the following line once debugged
            let image = UIImage()
            if let highScore = game.value(forKey: "highScore") as! Int?,
                let winner = game.value(forKey: "winner") as! String?,
                let date = game.value(forKey: "date") as! String? {
                let gameToAdd = Game(i: image, hs: highScore, w: winner, da: date)
                appDelegate.recordList.append(gameToAdd)
            }
        }
        print("RecordVC and the current fetched results count is: \(appDelegate.recordList.count)")
        recordsTableView.reloadData()
    }
    
    func retrieveRecords() -> [NSManagedObject] {
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserGame")
        
        var fetchedResults: [NSManagedObject]? = nil
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs, debug as follows
            let nserror = error as NSError
            NSLog("Unresolved Error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return (fetchedResults)!
    }
    
}
