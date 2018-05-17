//
//  CreateQueueViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 4/26/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit
import PromiseKit

class CreateQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var api = Api.api
    var searchController: UISearchController!
    var selectedMembers: Set<User> = []
    var queueName: String!
    var membersFromQuery: [User] = []
    
    @IBOutlet weak var selectedMembersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createQueueTapped(_ sender: UIButton) {
        firstly {
            api.createQueue(name: queueName, isPrivate: false, password: "", members: Array(selectedMembers))
        }.then { (result) in
            print("Created queue.")
        }.catch { (error) in
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.black
        updateAddedMembers()
        initializeSearch()
        initializeTable()
        
        definesPresentationContext = true
    }
    
    func initializeSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Add members"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func initializeTable() {
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        tableView.allowsMultipleSelection = true
    }
    
    func fetchData(query: String) {
        firstly {
            self.api.searchUsers(query: query)
        }.then { (result) -> Void in
            self.membersFromQuery = result
            self.tableView.reloadData()
        }.catch { (error) in
            print(error)
        }
    }
    
    /* Search View Delegate Methods */
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text!)
        fetchData(query: searchController.searchBar.text!)
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
        
        userCell?.userNameLabel.text = membersFromQuery[indexPath.row].username
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
        
        selectedMembers.insert(membersFromQuery[indexPath.row])
        userCell.accessoryType = .checkmark
        updateAddedMembers()
        searchController.searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let userCell = tableView.cellForRow(at: indexPath) as! UserCell
        
        selectedMembers.remove(membersFromQuery[indexPath.row])
        userCell.accessoryType = .none
        updateAddedMembers()
    }
    
    func updateAddedMembers() {
        if (selectedMembers.count == 0) {
            selectedMembersLabel.text = "none"
        } else {
            let extracted = selectedMembers.map { $0.username }
            selectedMembersLabel.text = extracted.joined(separator: ", ")
        }
    }
}
