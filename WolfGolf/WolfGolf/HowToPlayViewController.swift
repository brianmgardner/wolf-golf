//
//  HowToPlayViewController.swift
//  WolfGolf
//
//  Created by Ryan Resma on 7/7/20.
//  Copyright © 2020 gardner. All rights reserved.
//

import UIKit

class HowToPlayViewController: UIViewController {

    var delegate: UIViewController!
    @IBOutlet weak var rulesTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rulesTextView.isScrollEnabled = true
        self.rulesTextView.isUserInteractionEnabled = true
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
