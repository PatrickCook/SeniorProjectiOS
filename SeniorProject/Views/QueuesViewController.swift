
import UIKit
import SpotifyLogin
import DynamicBlurView

protocol PopoverDelegate {
    func popoverDismissed()
}

class QueuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PopoverDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var blurView: DynamicBlurView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                print(error.debugDescription)
                self?.showLoginFlow()
            }
        }
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search queues"
        searchController.searchBar.barStyle = .black
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0.0, y: 60.0)
        tableView.reloadData()
        
        definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showPopoverView" {
                if let viewController = segue.destination as? PopoverViewController {
                    blurView = DynamicBlurView(frame: view.bounds)
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.delegate = self
                    blurView.blurRadius = 10
                    view.addSubview(blurView)
                }
            }
        }
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let queueCell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueCell
        
        queueCell?.queueNameLabel.text = "Default Queue Name"
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
