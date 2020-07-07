//
//  ViewController.swift
//  WolfGolf
//
//  Created by Brian Gardner on 6/18/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    // segue constant id's
    let newGameSegueID = "newGameSegueIdentifier"
    let howToPlaySegueID = "howToPlaySegueIdentifier"
    let recordsSegueID = "recordsSegueIdentifier"
    let settingsSegueID = "settingsSegueIdentifier"
    
    // home screen image
    @IBOutlet weak var homeScreenImageView: UIImageView!
    
    // buttons
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var recordsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == newGameSegueID, let nextVC = segue.destination as? NewGameViewController {
//            // new game button clicked
//            nextVC.delegate = self
//        } else if segue.identifier == howToPlaySegueID, let nextVC = segue.destination as? HowToPlayViewController {
//            // how to play button clicked
//            nextVC.delegate = self
//        } else if segue.identifier == recordsSegueID, let nextVC = segue.destination as? RecordsViewController {
//            // records button clicked
//            nextVC.delegate = self
//        } else if segue.identifier == settingsSegueID, let nextVC = segue.destination as? SettingsViewController {
//            // settings button clicked
//            nextVC.delegate = self
//        }
    }
    
}

