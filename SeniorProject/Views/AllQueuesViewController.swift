
import SpotifyLogin
import DynamicBlurView
import PromiseKit
import UIKit
import ReSwift
import PusherSwift

protocol PopoverDelegate {
    func popoverDismissed()
}

class AllQueuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PopoverDelegate, StoreSubscriber {

    let pusher: Pusher = Pusher(
        key: "f24ae820c2a1b1Aacda",
        options: PusherClientOptions(host: .cluster("us2"))
    )
    
    var searchController: UISearchController!
    var blurView: DynamicBlurView!
    var queues: [Queue] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let channel = pusher.subscribe("my-channel")
        
        let _ = channel.bind(eventName: "my-event", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print(message)
                }
            }
            print("heereerer")
        })
        
        pusher.connect()
        
        // Check if user is logged in
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if (!isUserLoggedIn) {
            makeUserLogin()
        }
        
        mainStore.subscribe(self)
        fetchQueues()
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                print(error.debugDescription)
                self?.showLoginFlow()
            } else {
                MusicPlayer.shared.player?.login(withAccessToken: token)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeSearch()
        initializeTable()
        definesPresentationContext = true
    }
    
    func newState(state: AppState) {
       queues = state.joinedQueues
       tableView.reloadData()
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
    
    func fetchQueues() {
        showLoadingAlert(uiView: self.view)
        firstly {
            Api.shared.login(username: "pcook", password: "password")
        }.then { (result) -> Promise<[Queue]> in
            mainStore.dispatch(SetLoggedInUserAction(user: result))
            return Api.shared.getMyQueues()
        }.then { (result) -> Void in
            mainStore.dispatch(FetchedJoinedQueuesAction(joinedQueues: result)) 
            self.dismissLoadingAlert(uiView: self.view)
        }.catch { (error) in
            self.dismissLoadingAlert(uiView: self.view)
            self.showErrorAlert(error: error)
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
                if segue.destination is QueueViewController {
                    let queue = queues[(tableView.indexPathForSelectedRow?.row)!]
                    mainStore.dispatch(SetSelectedQueueAction(selectedQueue: queue))
                }
            default:
                break
            }
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
        let queueCell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueCell
        
        queueCell?.queueNameLabel.text = queues[indexPath.row].name
        queueCell?.currentSongLabel.text = "Default Song Name"
        
        return queueCell!
    }
    
    
    /* Helpers */
    func makeUserLogin() {
        self.performSegue(withIdentifier: "makeUserLogin", sender: self)
    }
    
    func showLoginFlow() {
        self.performSegue(withIdentifier: "home_to_login", sender: self)
    }
    
    func popoverDismissed() {
        blurView.blurRadius = 0
        blurView.remove()
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        makeUserLogin()
        SpotifyLogin.shared.logout()
        self.showLoginFlow()
    }
    
    @IBAction func unwindToQueuesView(sender:UIStoryboardSegue) {
        blurView.blurRadius = 0
        blurView.remove()
        fetchQueues()
    }
    
    @IBAction func openMusicPlayerTapped(_ sender: Any) {
        print("open music player")
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
            self.present(mvc, animated: true, completion: nil)
        }
    }
}
