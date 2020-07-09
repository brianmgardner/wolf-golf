//
//  RecordsViewController.swift
//  WolfGolf
//
//  Created by Ryan Resma on 7/7/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit
import CoreData

protocol RecordAdder {
    // MARK: need a game object
    func addRecord(game: Game)
}

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecordAdder {
    
    let tableCellID = "RecordCellIdentifier"
    
    var delegate: UIViewController!
    var myRecordList: [Game] = []
    
    @IBOutlet weak var recordsTableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRecordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellID, for: indexPath) as! RecordTableViewCell
        let currRecord = myRecordList[indexPath.row]
        // modify the current attributes of the cell's UI as necessary
        cell.cellImageView.image = currRecord.image
        cell.cellGameWinnerLabel.text = "Game Winner: \(currRecord.winner!)"
        cell.cellDateLabel.text = "Date: \(currRecord.date!)"
        
        return cell
    }
    
    // handle an alert/modal with all of the game's data
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currRecord = myRecordList[indexPath.row]
        let gameTitle = "\(currRecord.winner!) won the game!"
        let numHoles = appDelegate.isNineHole ? 9 : 18
        let gameMessage = "Date: \(currRecord.date!) \nHigh score: \(currRecord.highScore!) \n\nNumber of Holes played: \(numHoles)"
        let controller = UIAlertController(title: gameTitle,
                                           message: gameMessage, preferredStyle: .alert)
        // thin crust option
        controller.addAction(UIAlertAction(title: "GG \(currRecord.winner!)", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    // remove the selected game record from our list and delete the UI tableViewCell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recordToBeRemoved = myRecordList[indexPath.row]
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserGame")
            
            var fetchedResults: [NSManagedObject]
            
            // search fields must match exactly
            // note: can't query by image binary data 
            let predicateWinner = NSPredicate(format: "winner == %@", recordToBeRemoved.winner!)
            let predicateDate = NSPredicate(format: "date == %@", recordToBeRemoved.date!)
            let predicateHighScore = NSPredicate(format: "highScore == %d", recordToBeRemoved.highScore!)

            let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateWinner, predicateDate, predicateHighScore])

            request.predicate = andPredicate
            
            do {
                // fetch and delete
                try fetchedResults = context.fetch(request) as! [NSManagedObject]
                if fetchedResults.count > 0 {
                    for result:AnyObject in fetchedResults {
                        context.delete(result as! NSManagedObject)
                    }
                }
                try context.save()
                print("deleting a core data entity success!")
            } catch {
                // if an error occurs
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            appDelegate.recordList.remove(at: indexPath.row)
            myRecordList.remove(at: indexPath.row)
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
        self.recordsTableView.rowHeight = UITableView.automaticDimension
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
        myRecordList = appDelegate.recordList
        print("RecordVC and the current fetched results count is: \(myRecordList.count)")
        recordsTableView.reloadData()
        print("Done reloading data")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.recordList = []
        myRecordList = []
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
