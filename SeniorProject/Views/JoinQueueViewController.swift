//
//  JoinQueueViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/3/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class JoinQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search queues..."
        searchController.searchBar.barStyle = .black
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        tableView.allowsSelection = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        
        definesPresentationContext = true
    }
    
    /* Search View Delegate Methods */
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text)
        // TODO: Search queues using name
    }
    
    /* Search Bar Delegate Methods */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("Search")
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let joinQueueCell = tableView.cellForRow(at: indexPath!) as! JoinQueueCell
        let queueAlertTitle = "Join queue " + joinQueueCell.queueNameLabel.text! + "?"
        let alertController = UIAlertController(title: queueAlertTitle, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let saveAction = UIAlertAction(title: "Join", style: UIAlertActionStyle.default, handler: { alert -> Void in
            print("Joining queue: " + joinQueueCell.queueNameLabel.text!)
            //TODO: Join queue using API
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
