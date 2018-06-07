
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
    @IBOutlet weak var currentSongAlbumImage: UIImageView!
    
    @IBAction func openMusicPlayerTapped(_ sender: Any) {
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
            self.present(mvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func resumeQueueTapped(_ sender: UIButton) {
        handlePlaybackOwnership()  
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        self.title = queue.name
    }
    
    override func viewDidLoad() {
        mainStore.subscribe(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initializeData()
        refreshResumeButton()
        resumeQueueButton.layer.cornerRadius = 20
        resumeQueueButton.clipsToBounds = true
    }
    
    func newState(state: AppState) {
        let url: URL
        
        queue = state.selectedQueue
        songs = (state.selectedQueue?.songs)!
        queuedByLabel.text = state.selectedQueueCurrentSong?.queuedBy
        currentSongLabel.text = state.selectedQueueCurrentSong?.title
        
        if (songs.count > 0) {
            url = URL(string: (songs.first?.imageURI)!)!
            currentSongAlbumImage.kf.indicatorType = .activity
            currentSongAlbumImage.kf.setImage(with: url, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image == nil) {
                    self.currentSongAlbumImage.image = UIImage(named: "default-album-cover")
                }
            })
        }
        
        refreshResumeButton()
        
        tableView.reloadData()
    }
    
    func refreshResumeButton() {
        let userId = mainStore.state.loggedInUser?.id
        let playingUserId = mainStore.state.playingQueue.playingUserId
        let isPlaying = (mainStore.state.selectedQueue?.isPlaying)!
        
        if (playingUserId == userId) {
            resumeQueueButton.isEnabled = true
            resumeQueueButton.setTitle(isPlaying ? "Stop Queue" : "Start Queue", for: .normal)
        } else if (isPlaying) {
            resumeQueueButton.isEnabled = false
            resumeQueueButton.setTitle("Playing...", for: .normal)
        } else {
            resumeQueueButton.setTitle("Start Queue", for: .normal)
        }
    }
    
    func handlePlaybackOwnership() {
        var playingQueueId = mainStore.state.playingQueue.id
        let selectedQueueId = mainStore.state.selectedQueue?.id
        let isPlaying = mainStore.state.playingQueue.isPlaying

        if (isPlaying && playingQueueId != selectedQueueId) {
            Api.shared.setQueueIsPlaying(queueId: playingQueueId, isPlaying: false)
            mainStore.dispatch(SetQueueIsPlayingAction(isPlaying: false))
            mainStore.dispatch(StopPlaybackAction())
            mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
            mainStore.dispatch(TogglePlaybackAction())
            mainStore.dispatch(SetQueueIsPlayingAction(isPlaying: true))
            Api.shared.setQueueIsPlaying(queueId: selectedQueueId!, isPlaying: true)
        } else if (isPlaying) {
            mainStore.dispatch(StopPlaybackAction())
            mainStore.dispatch(SetQueueIsPlayingAction(isPlaying: false))
            Api.shared.setQueueIsPlaying(queueId: playingQueueId, isPlaying: false)
        } else {
            mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
            mainStore.dispatch(TogglePlaybackAction())
            mainStore.dispatch(SetQueueIsPlayingAction(isPlaying: true))
            playingQueueId = mainStore.state.playingQueue.id
            Api.shared.setQueueIsPlaying(queueId: playingQueueId, isPlaying: true)
        }
        
    }
    
    func initializeData() {
        showLoadingAlert(uiView: self.view)
        
        firstly {
            Api.shared.getSelectedQueue(queue: queue)
        }.then { (result) -> Void in
            mainStore.dispatch(FetchedSelectedQueueAction(selectedQueue: result))
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
