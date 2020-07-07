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
    func addRecord(game: Any)
}

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecordAdder {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
    // protocol method to change the current game list
    func addRecord(game: Any) {
        <#code#>
    }
    

    @IBOutlet weak var recordsTableView: UITableView!
    
    var recordList: [Any] = []
    
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
