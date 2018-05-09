//
//  CreateQueueViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 4/26/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class CreateQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController: UISearchController!
    var selectedMembers: Set<String> = []
    var queueName: String!
    var membersFromQuery: [String] = ["userA", "userB", "userC", "userD"]
    
    @IBOutlet weak var selectedMembersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createQueueTapped(_ sender: UIButton) {
        print("Create queue: " + queueName)
        print("Add members: " + selectedMembers.joined(separator: ", "))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.black
        refreshAddedMembers()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Add members"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        tableView.allowsMultipleSelection = true
        
        definesPresentationContext = true
    }
    
    /* Search View Delegate Methods */
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text!)
    }
    
    /* Search Bar Delegate Methods */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("Search: " + searchBar.text!)
        //TODO: Search members using text and API
    }

    /* Table View Delegate Methods */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersFromQuery.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell
        
        userCell?.userNameLabel.text = membersFromQuery[indexPath.row]
        userCell?.tintColor = .white
        userCell?.selectionStyle = .none

        /* Make sure another search will persist users previously added */
        if (selectedMembers.contains(membersFromQuery[indexPath.row])) {
            userCell?.accessoryType = .checkmark
        } else {
            userCell?.accessoryType = .none
        }
        
        return userCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userCell = tableView.cellForRow(at: indexPath) as! UserCell
        
        selectedMembers.insert(userCell.userNameLabel.text!)
        userCell.accessoryType = .checkmark
        refreshAddedMembers()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let userCell = tableView.cellForRow(at: indexPath) as! UserCell
        
        selectedMembers.remove(userCell.userNameLabel.text!)
        userCell.accessoryType = .none
        refreshAddedMembers()
    }
    
    func refreshAddedMembers() {
        if (selectedMembers.count == 0) {
            selectedMembersLabel.text = "none"
        } else {
            selectedMembersLabel.text = selectedMembers.joined(separator: ", ")
        }
    }
}
