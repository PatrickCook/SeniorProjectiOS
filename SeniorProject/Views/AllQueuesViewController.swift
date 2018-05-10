
import UIKit
import SpotifyLogin
import DynamicBlurView
import PromiseKit

protocol PopoverDelegate {
    func popoverDismissed()
}

class QueuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PopoverDelegate {
    
    var api = Api.api
    var searchController: UISearchController!
    var blurView: DynamicBlurView!
    var queues: [Queue] = Store.currentQueues
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                print(error.debugDescription)
                self?.showLoginFlow()
            }
        }
        
        initializeSearch()
        initializeTable()
        
        
        definesPresentationContext = true
    }
    
    func initializeSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search queues"
        searchController.searchBar.barStyle = .black
    }
    
    func initializeTable() {
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0.0, y: 60.0)
        tableView.reloadData()
    }
    
    func initializeData() {
        showLoadingAlert()
        firstly {
            self.api.login(username: "admin", password: "password")
        }.then { (result) -> Promise<[Queue]> in
            self.api.getAllQueues()
        }.then { (result) -> Void in
            self.dismissLoadingAlert()
            self.tableView.reloadData()
            print("finished initializing data")
        }.catch { (error) in
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showPopoverView":
                if let viewController = segue.destination as? PopoverViewController {
                    blurView = DynamicBlurView(frame: view.bounds)
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.delegate = self
                    blurView.blurRadius = 10
                    view.addSubview(blurView)
                }
            case "show_queue_from_row", "show_queue_from_accessory":
                Store.setSelectedQueue(index: (tableView.indexPathForSelectedRow?.row)!)
            default:
                break
            }
        }
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Store.currentQueues.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let queueCell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueCell
        
        queueCell?.queueNameLabel.text = Store.currentQueues[indexPath.row].name
        queueCell?.currentSongLabel.text = "Default Song Name"
        
        return queueCell!
    }
    
    
    /* Helpers */
    func showLoginFlow() {
        //self.performSegue(withIdentifier: "home_to_login", sender: self)
    }
    
    func popoverDismissed() {
        blurView.blurRadius = 0
        blurView.remove()
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        SpotifyLogin.shared.logout()
        self.showLoginFlow()
    }
    
    @IBAction func unwindToQueuesView(sender:UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateQueueViewController {
            //Create queue unwind
        } else if let sourceViewController = sender.source as? JoinQueueViewController {
            //Create queue unwind
        }
        blurView.blurRadius = 0
        blurView.remove()
    }
}
