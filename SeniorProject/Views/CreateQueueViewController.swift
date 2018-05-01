//
//  CreateQueueViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 4/26/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class CreateQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var queueNameInput: UITextField!
    @IBOutlet weak var queuePasswordInput: UITextField!
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func createQueueTapped(_ sender: UIButton) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.black
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Add members"
        searchController.searchBar.barStyle = .black
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        
        definesPresentationContext = true
    }

    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell
        
        userCell?.userNameLabel.text = "default_user"
        
        return userCell!
    }
}