//
//  SettingsViewController.swift
//  WolfGolf
//
//  Created by Ryan Resma on 7/7/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var isNightMode: Bool = false
    
    @IBOutlet weak var gameVariationLabel: UILabel!
    @IBAction func gameVariationSwitchChanged(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isVariation1 {
            appDelegate.isVariation1 = false
            self.gameVariationLabel.text = "Game Variation 2"
            // MARK: call protocol method here
        } else {
            appDelegate.isVariation1 = true
            self.gameVariationLabel.text = "Game Variation 1"
            // MARK: call protocol method here?
        }
    }
    

    @IBAction func nightModeSwitchChanged(_ sender: UISwitch) {
        if !isNightMode {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
        
    }
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
