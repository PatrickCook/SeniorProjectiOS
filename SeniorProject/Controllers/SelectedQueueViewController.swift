
import UIKit
import SpotifyLogin
import PromiseKit
import ReSwift
import SwiftyJSON

class SelectedQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, StoreSubscriber {
    
    var queue: Queue!
    var songs: [Song] = []
  
    @IBOutlet var miniMusicPlayerView: MiniMusicPlayerView!
    @IBOutlet var miniMusicPlayerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var queuedByLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var queueDetailView: UIView!
    @IBOutlet weak var resumeQueueButton: UIButton!
    @IBOutlet weak var currentSongAlbumImage: UIImageView!
    
    /* Opens the music player */
    @IBAction func openMusicPlayerTapped(_ sender: Any) {
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
            self.present(mvc, animated: true, completion: nil)
        }
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    /* Button associated with the play button on the bottom of the screen */
    @IBAction func changePlaybackButtonPressed(_ sender: UIButton) {
        handlePlaybackOwnership()
        updatePlaybackButtonText()
    }
    
    override func viewDidLoad() {
        mainStore.subscribe(self)
        self.navigationItem.title = queue.name
        
        print("SETTING UP PUSHER & BINDING EVENTS")
        let channel = PusherController.shared.pusher.subscribe("my-channel")
        
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
        
        fetchSelectedQueue()
        updatePlaybackButtonText()
        updateMiniMusicPlayerVisibility()
        
        resumeQueueButton.layer.cornerRadius = resumeQueueButton.frame.height*0.5
        resumeQueueButton.clipsToBounds = true
    }
    
    func newState(state: AppState) {
        let url: URL
        
        guard let stateSelectedQueue = state.selectedQueue else {
            print("QueueViewController: Selected Queue not set, cannot accept new state")
            return
        }
        
        queue = stateSelectedQueue
        songs = queue.songs
        
        if let currentSong = songs.first {
            queuedByLabel.text = currentSong.queuedBy
            currentSongLabel.text = currentSong.title
            
            url = URL(string: currentSong.imageURI)!
            currentSongAlbumImage.kf.indicatorType = .activity
            currentSongAlbumImage.kf.setImage(with: url, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image == nil) {
                    self.currentSongAlbumImage.image = UIImage(named: "default-album-cover")
                }
            })
        } else {
            queuedByLabel.text = "--"
            currentSongLabel.text = "--"
            currentSongAlbumImage.image = UIImage(named: "default-album-cover")
        }
        
        updatePlaybackButtonText()
        
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
    
    func updateMiniMusicPlayerVisibility() {
        if let _ = mainStore.state.playingQueue {
            miniMusicPlayerView.isHidden = false
        } else {
            miniMusicPlayerView.isHidden = true
        }
    }
    
    /*
     * Responsible with updating what the play button looks like
     * depending on the state of the music playback
     */
    func updatePlaybackButtonText() {
        guard let loggedInUser = mainStore.state.loggedInUser else {
            print("QueueViewController: User not logged in")
            return
        }
        
        let userId = loggedInUser.id
        let playingUserId = queue.playingUserId
        let isPlaying = queue.isPlaying
        
        if (playingUserId == userId) { /* User is playing queue */
            resumeQueueButton.isEnabled = true
            resumeQueueButton.setTitle("Stop Queue", for: .normal)
        } else if (isPlaying) {        /* Another user is playing queue */
            resumeQueueButton.isEnabled = false
            resumeQueueButton.setTitle("Playing...", for: .normal)
        } else {                       /* Queue is not being played  */
            resumeQueueButton.isEnabled = true
            resumeQueueButton.setTitle("Start Queue", for: .normal)
        }
    }
    
    /* Handles who owns which queue */
    func handlePlaybackOwnership() {
        let loggedInUserId = mainStore.state.loggedInUser!.id
        let selectedQueue = mainStore.state.selectedQueue
        let playingQueue = mainStore.state.playingQueue
        let isSelectedQueuePlaying = mainStore.state.selectedQueue!.isPlaying

        /* Logged In User is Controlling Playback of a Queue
         * Is it playing and the selected queue and playing queue are the same
         */
        if (loggedInUserId == selectedQueue!.playingUserId && isSelectedQueuePlaying) {
            MusicPlayer.shared.pausePlayback()
            mainStore.dispatch(SetPlayingQueueToNilAction())
            updateMiniMusicPlayerVisibility()
            
            Api.shared.setQueueIsPlaying(queueId: selectedQueue!.id, isPlaying: false)
        }
        /*
         * User is playing a queue but trying to swap
         */
        else if (playingQueue != nil && playingQueue!.id != selectedQueue!.id) {
            MusicPlayer.shared.pausePlayback()
            
            Api.shared.setQueueIsPlaying(queueId: playingQueue!.id, isPlaying: false)
            
            mainStore.dispatch(SetPlayingQueueToNilAction())
            mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
            
            MusicPlayer.shared.resetPlayback()
            MusicPlayer.shared.togglePlayback()
            
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
            MusicPlayer.shared.togglePlayback()
            updateMiniMusicPlayerVisibility()
            Api.shared.setQueueIsPlaying(queueId: selectedQueue!.id, isPlaying: true)
        }
        else {
            print("A case that was unexpected happened in handlePlaybackOwnership()")
        }
    }
    
    func fetchSelectedQueue() {
        //showLoadingAlert(uiView: self.view)
        
        Api.shared.getSelectedQueue(queue: queue)
            .then { (result) -> Void in
                mainStore.dispatch(FetchedSelectedQueueAction(selectedQueue: result))
//                if (self.queue.isPlaying && self.queue.playingUserId == mainStore.state.loggedInUser!.id) {
//                    mainStore.dispatch(SetSelectedQueueAsPlayingQueue())
//                }
                //self.dismissLoadingAlert(uiView: self.view)
            }.catch { (error) in
                //self.dismissLoadingAlert(uiView: self.view)
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
        let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
        let song = songs[indexPath.row]
        
        songCell.song = song
        songCell.songNameLabel.text = song.title
        songCell.queuedByLabel.text = song.queuedBy
        songCell.votesLabel.text = "\(song.votes)"
        
        if song.isPlaying {
            songCell.voteButton.isEnabled = false
        }
        
        if song.didUserVote(userId: (mainStore.state.loggedInUser?.id)!) {
            songCell.voteButton.tintColor =  #colorLiteral(red: 0.3803921569, green: 0.6980392157, blue: 0.9764705882, alpha: 1)
        } else {
            songCell.voteButton.tintColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        return songCell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let songId = mainStore.state.selectedQueue?.songs[indexPath.row].id
            
            Api.shared.dequeueSong(queueId: self.queue.id, songId: songId!)
                .then { (result) -> Void in
                    mainStore.dispatch(RemoveSongFromSelectedQueueAction(songId: songId!))
                }.catch { (error) in
                    self.showErrorAlert(error: error)
                }
            
            tableView.reloadData()
        }

        
        return [delete]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "moveToSearch":
                if let viewController = segue.destination as? SpotifySongSearchViewController {
                    viewController.queueToAddTo = queue
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToSelectedQueueVC(segue: UIStoryboardSegue) {
        
    }
}
