
import UIKit
import SpotifyLogin
import PromiseKit
import ReSwift

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, StoreSubscriber {
    
    var songs: [Song] = []
    var queue: Queue!
    
    @IBOutlet weak var queuedByLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var queueDetailView: UIView!
    @IBOutlet weak var resumeQueueButton: UIButton!
    
    @IBAction func openMusicPlayerTapped(_ sender: Any) {
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
            self.present(mvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func resumeQueueTapped(_ sender: UIButton) {
        print("Resume queue handler")
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        self.title = queue.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
        initializeData()
        
        resumeQueueButton.layer.cornerRadius = 20
        resumeQueueButton.clipsToBounds = true
    }
    
    func newState(state: AppState) {
        queue = state.selectedQueue
        songs = (state.selectedQueue?.songs)!
        queuedByLabel.text = state.selectedQueueCurrentSong?.queuedBy
        currentSongLabel.text = state.selectedQueueCurrentSong?.title
        tableView.reloadData()
    }
    
    
    func initializeData() {
        showLoadingAlert(uiView: self.view)
        
        firstly {
            Api.shared.getSelectedQueue(queue: queue)
        }.then { (result) -> Void in
            mainStore.dispatch(FetchedSelectedQueueAction(selectedQueue: result))
            mainStore.dispatch(SetSelectedQueueCurrentSong())
            self.dismissLoadingAlert(uiView: self.view)
        }.catch { (error) in
            self.dismissLoadingAlert(uiView: self.view)
            self.showErrorAlert(error: error)
        }
    }
    
    /* Segue in order to search for songs */
    @IBAction func addSongSegue(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "moveToSearch", sender: self)
    }
    
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
        
        songCell?.song = songs[indexPath.row]
        songCell?.songNameLabel.text = songs[indexPath.row].title
        songCell?.queuedByLabel.text = songs[indexPath.row].queuedBy
        songCell?.votesLabel.text = "\(songs[indexPath.row].votes)"
        
        return songCell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "moveToSearch":
                if let viewController = segue.destination as? SongSearchViewController {
                    viewController.queueToAddTo = queue
                }
            default:
                break
            }
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        initializeData()
        tableView.reloadData()
    }
}
