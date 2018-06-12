
import UIKit
import SpotifyLogin
import PromiseKit
import ReSwift
import SwiftyJSON

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, StoreSubscriber {
    
    var songs: [Song] = []
    var queue: Queue!
    
    @IBOutlet weak var navItem: UINavigationItem!
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
    }
    
    override func viewDidLoad() {
        mainStore.subscribe(self)
        self.navigationItem.title = queue.name
        fetchSelectedQueue()
        
        let channel = PusherUtil.shared.pusher.subscribe("my-channel")
        
        let _ = channel.bind(eventName: "queue-playback-changed", callback: { (data: Any?) -> Void in
            print("Pusher: queue-playback-changed")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
        
        let _ = channel.bind(eventName: "song-upvoted", callback: { (data: Any?) -> Void in
            print("Pusher: song-upvoted")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
        
        let _ = channel.bind(eventName: "song-added-to-queue", callback: { (data: Any?) -> Void in
            print("Pusher: song-added-to-queue")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
        
        let _ = channel.bind(eventName: "song-deleted-from-queue", callback: { (data: Any?) -> Void in
            print("Pusher: song-deleted-from-queue")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshResumeButton()
        resumeQueueButton.layer.cornerRadius = 20
        resumeQueueButton.clipsToBounds = true
    }
    
    func newState(state: AppState) {
        let url: URL
        
        queue = state.selectedQueue
        songs = state.selectedQueue?.songs ?? []
        queuedByLabel.text = state.selectedQueue?.songs.first?.queuedBy
        currentSongLabel.text = state.selectedQueue?.songs.first?.title
        
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
    
    func refreshSelectedAndPlayingQueueAfterTrigger(json: JSON) {
        if (json["queueId"].intValue == queue.id) {
            firstly {
                Api.shared.getSelectedQueue(queue: queue)
            }.then { (result) -> Void in
                mainStore.dispatch(FetchedSelectedQueueAction(selectedQueue: result))
                if (json["queueId"].intValue == mainStore.state.playingQueue?.id) {
                    mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
                }
            }.catch { (error) in
                self.showErrorAlert(error: error)
            }
        }
    }
    
    func refreshResumeButton() {
        let userId = mainStore.state.loggedInUser!.id
        let playingUserId = mainStore.state.selectedQueue?.playingUserId ?? -1
        let isPlaying = mainStore.state.selectedQueue?.isPlaying ?? false
        
        if (playingUserId == userId) {
            resumeQueueButton.isEnabled = true
            resumeQueueButton.setTitle(isPlaying ? "Stop Queue" : "Start Queue", for: .normal)
        } else if (isPlaying) {
            resumeQueueButton.isEnabled = false
            resumeQueueButton.setTitle("Playing...", for: .normal)
        } else {
            resumeQueueButton.isEnabled = true
            resumeQueueButton.setTitle("Start Queue", for: .normal)
        }
    }
    
    func handlePlaybackOwnership() {
        let loggedInUserId = mainStore.state.loggedInUser!.id
        let selectedQueue = mainStore.state.selectedQueue
        let playingQueue = mainStore.state.playingQueue
        let isSelectedQueuePlaying = mainStore.state.selectedQueue!.isPlaying

        /* Logged In User is Controlling Playback of a Queue
         * Is it playing and the selected queue and playing queue are the same
         */
        if (loggedInUserId == selectedQueue!.playingUserId && isSelectedQueuePlaying) {
            mainStore.dispatch(StopPlaybackAction())
            mainStore.dispatch(SetPlayingQueueToNilAction())
            Api.shared.setQueueIsPlaying(queueId: selectedQueue!.id, isPlaying: false)
        }
        /*
         * User is playing a queue but trying to swap
         */
        else if (playingQueue != nil && playingQueue!.id != selectedQueue!.id) {
            print("Supposed to swap")
            mainStore.dispatch(StopPlaybackAction())
            Api.shared.setQueueIsPlaying(queueId: playingQueue!.id, isPlaying: false)
            mainStore.dispatch(SetPlayingQueueToNilAction())
            mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
            mainStore.dispatch(ResetMusicPlayerStateAction())
            mainStore.dispatch(TogglePlaybackAction())
            Api.shared.setQueueIsPlaying(queueId: selectedQueue!.id, isPlaying: true)
        }
        /*
         * User is viewing a playing queue
         */
        else if (loggedInUserId != selectedQueue!.playingUserId && isSelectedQueuePlaying) {
            print("This case should never happen")
        }
        /*
         * PLAYING QUEUE IS NIL, PLAY SELECTED QUEUE
         */
        else if (selectedQueue!.playingUserId == -1){
            mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
            mainStore.dispatch(TogglePlaybackAction())
            Api.shared.setQueueIsPlaying(queueId: selectedQueue!.id, isPlaying: true)
        }
        else {
            print("A case that was unexpected happened in handlePlaybackOwnership()")
        }
    }
    
    func fetchSelectedQueue() {
        showLoadingAlert(uiView: self.view)
        
        firstly {
            Api.shared.getSelectedQueue(queue: queue)
            }.then { (result) -> Void in
                mainStore.dispatch(FetchedSelectedQueueAction(selectedQueue: result))
                if (self.queue.isPlaying && self.queue.playingUserId == mainStore.state.loggedInUser!.id) {
                    mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
                }
                self.dismissLoadingAlert(uiView: self.view)
            }.catch { (error) in
                self.dismissLoadingAlert(uiView: self.view)
                self.showErrorAlert(error: error)
        }
    }
    
    func refreshSelectedQueue() {
        print("Refreshing Selected Queue....")
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let songId = mainStore.state.selectedQueue?.songs[indexPath.row].id
            mainStore.dispatch(RemoveSongFromSelectedQueueAction(songId: songId!))
            Api.shared.dequeueSong(queueId: self.queue.id, songId: songId!);
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        
        return [delete]
        
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
        
    }
}
