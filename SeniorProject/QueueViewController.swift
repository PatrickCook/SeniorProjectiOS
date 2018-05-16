
import UIKit
import SpotifyLogin
import PromiseKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let api = Api.api
    var songs: [Song] = []
    var queue: Queue!
    
    @IBOutlet weak var queuedByLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func openMusicPlayerTapped(_ sender: Any) {
        print("open music player")
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
            self.present(mvc, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = queue.name
        initializeData()
    }
    
    func initializeData() {
        self.showLoadingAlert()
        firstly {
            self.api.getSelectedQueue(queue: queue)
        }.then { (result) -> Void in
            self.dismissLoadingAlert()
            self.songs = self.queue.songs
            self.queuedByLabel.text = self.queue.currentSong?.userId.description
            self.currentSongLabel.text = self.queue.currentSong?.spotifyURI
            self.tableView.reloadData()
        }.catch { (error) in
            print(error)
        }
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
        
        songCell?.songNameLabel.text = songs[indexPath.row].spotifyURI
        songCell?.queuedByLabel.text = "\(songs[indexPath.row].userId)"
        songCell?.votesLabel.text = "\(songs[indexPath.row].votes)"
        
        return songCell!
    }
}
