//
//  JoinQueueViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/3/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class JoinQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let queueCell = tableView.dequeueReusableCell(withIdentifier: "joinQueueCell", for: indexPath) as? JoinQueueCell
        
        queueCell?.queueNameLabel.text = "Default Queue Name"
        
        return queueCell!
    }
}
