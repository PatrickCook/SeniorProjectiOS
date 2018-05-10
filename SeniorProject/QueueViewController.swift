
import UIKit
import SpotifyLogin
import PromiseKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let api = Api.api
    var songs: [Song] = []
    
    @IBOutlet weak var queuedByLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = Store.selectedQueue?.name
        initializeData()
    }
    
    func initializeData() {
        self.showLoadingAlert()
        firstly {
            self.api.getSelectedQueue()
        }.then { (result) -> Void in
            self.dismissLoadingAlert()
            self.songs = (Store.selectedQueue?.songs)!
            self.queuedByLabel.text = Store.selectedQueue?.currentSong?.userId.description
            self.currentSongLabel.text = Store.selectedQueue?.currentSong?.spotifyURI
            self.tableView.reloadData()
            print("finished initializing songs")
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
