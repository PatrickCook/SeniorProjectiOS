//
//  JoinQueueViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/3/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit
import PromiseKit

class JoinQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var api = Api.api
    var searchController: UISearchController!
    var queues: [Queue] = []
    var selectedQueue: Queue!
    
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
    }
    
    /* Search Bar Delegate Methods */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        fetchQueues(query: searchController.searchBar.text!)
    }
    
    func fetchQueues(query: String) {
        firstly {
            self.api.getAllQueues(with: query)
        }.then { (result) -> Void in
            self.queues = result
            self.tableView.reloadData()
        }.catch { (error) in
            print(error)
        }
    }
    
    func joinQueue(withPassword: String!) {
        firstly {
            self.api.joinQueue(queueId: self.selectedQueue.id, password: withPassword)
        }.then { (result) -> Void in
            self.performSegue(withIdentifier: "unwind_to_all_queues", sender: self)
        }.catch { (error) in
            print(error)
        }
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queues.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let queueCell = tableView.dequeueReusableCell(withIdentifier: "joinQueueCell", for: indexPath) as? JoinQueueCell
        
        queueCell?.queueNameLabel.text = queues[indexPath.row].name
        queueCell?.queueOwnerLabel.text = queues[indexPath.row].owner
        
        return queueCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let joinQueueCell = tableView.cellForRow(at: indexPath) as! JoinQueueCell
        let queueAlertTitle = "Join queue " + joinQueueCell.queueNameLabel.text! + "?"
        let alertController = UIAlertController(title: queueAlertTitle, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let saveAction = UIAlertAction(title: "Join", style: UIAlertActionStyle.default, handler: { alert -> Void in
            print("Joining queue: " + joinQueueCell.queueNameLabel.text!)
            self.joinQueue(withPassword: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        //Set selected queue because we are going to deselect it in the table view
        selectedQueue = queues[indexPath.row]
        
        //Add actions
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        //Dismiss in case the active view is search controller
        if searchController.isActive {
            searchController.present(alertController, animated: true, completion: nil)
        } else {
            self.present(alertController, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
