
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
        mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
        handlePlaybackOwnership()  
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        self.title = queue.name
    }
    
    override func viewDidLoad() {
        mainStore.subscribe(self)
        initializeData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resumeQueueButton.layer.cornerRadius = 20
        resumeQueueButton.clipsToBounds = true
    }
    
    func newState(state: AppState) {
        let url = URL(string: state.playingSong.imageURI)!
        let isPlaying = (mainStore.state.selectedQueue?.isPlaying)!
        
        queue = state.selectedQueue
        songs = (state.selectedQueue?.songs)!
        queuedByLabel.text = state.selectedQueueCurrentSong?.queuedBy
        currentSongLabel.text = state.selectedQueueCurrentSong?.title
        
        currentSongAlbumImage.kf.indicatorType = .activity
        currentSongAlbumImage.kf.setImage(with: url, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image == nil) {
                self.currentSongAlbumImage.image = UIImage(named: "default-album-cover")
            }
        })
        
        self.resumeQueueButton.setTitle(isPlaying ? "Stop Queue" : "Start Queue", for: .normal)
        
        tableView.reloadData()
    }
    
    func handlePlaybackOwnership() {
        let queueId = mainStore.state.playingQueue.id
        let isPlaying = mainStore.state.playingQueue.isPlaying
        
        firstly {
            Api.shared.setQueueIsPlaying(queueId: queueId, isPlaying: !isPlaying)
            }.then { (result) -> Void in
                mainStore.dispatch(SetQueueIsPlayingAction(isPlaying: !isPlaying))
                
                if (isPlaying) {
                    mainStore.dispatch(StopPlaybackAction())
                } else {
                    mainStore.dispatch(TogglePlaybackAction())
                }
            }.catch { (error) in
                print(error)
                self.showErrorAlert(error: error)
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
