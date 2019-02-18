
import SpotifyLogin
import DynamicBlurView
import PromiseKit
import UIKit
import ReSwift
import PusherSwift

protocol PopoverDelegate {
    func popoverDismissed()
}

class AllQueuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PopoverDelegate, StoreSubscriber, PusherDelegate {
    
    var searchController: UISearchController!
    var blurView: DynamicBlurView!
    var queues: [Queue] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        mainStore.subscribe(self)
        validateUserAuthenticated()
        validateSpotifyAuthenticated()
        fetchQueues()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func validateSpotifyAuthenticated() {
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                print(error.debugDescription)
                self?.makeUserLogin()
            } else {
                MusicPlayer.shared.player.login(withAccessToken: token)
            }
        }
    }
    
    func validateUserAuthenticated() {
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if (isUserLoggedIn) {
            if let data = UserDefaults.standard.data(forKey: "loggedInUser"),
                let loggedInUser = NSKeyedUnarchiver.unarchiveObject(with: data) as? User {
                mainStore.dispatch(SetLoggedInUserAction(user: loggedInUser))
                print("Logged In User: \(loggedInUser.username)")
            } else {
                print("User is logged in but was not saved in UserDefaults correctly")
            }
        } else {
            makeUserLogin()
        }
    }
    
    func newState(state: AppState) {
       queues = state.joinedQueues
       tableView.reloadData()
    }
    
    func fetchQueues() {
        showLoadingAlert(uiView: self.view)
        
        Api.shared.getMyQueues()
            .then { (result) -> Void in
                mainStore.dispatch(FetchedJoinedQueuesAction(joinedQueues: result))
                self.dismissLoadingAlert(uiView: self.view)
            }.catch { (error) in
                self.dismissLoadingAlert(uiView: self.view)
                self.makeUserLogin()
                //self.showErrorAlert(error: error)
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
        queueCell?.currentSongLabel.text = "\(queues[indexPath.row].songs.count) Songs"
        
        return queueCell!
    }
    
    
    /* Helpers */
    func makeUserLogin() {
        self.performSegue(withIdentifier: "moveToLogin", sender: self)
    }
    
    func showLoginFlow() {
        self.performSegue(withIdentifier: "home_to_login", sender: self)
    }
    
    func popoverDismissed() {
        blurView.blurRadius = 0
        blurView.remove()
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        Api.shared.getMyQueues()
            .then { (result) -> Void in
                mainStore.dispatch(FetchedJoinedQueuesAction(joinedQueues: result))
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }.catch { (error) in
                self.showErrorAlert(error: error)
        }
    }
    
    
    @IBAction func didTapLogout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
        
        if (mainStore.state.playingQueue != nil) {
            let id = mainStore.state.playingQueue!.id
            mainStore.dispatch(StopPlaybackAction())
            mainStore.dispatch(SetPlayingQueueToNilAction())
            Api.shared.setQueueIsPlaying(queueId: id, isPlaying: false)
        }
        
        
        SpotifyLogin.shared.logout()
        makeUserLogin()
    }
    
    @IBAction func openMusicPlayerTapped(_ sender: Any) {
        print("open music player")
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
            self.present(mvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindToAllQueues(segue: UIStoryboardSegue) {
        popoverDismissed()
        fetchQueues()
    }
}
