
import UIKit
import SpotifyLogin
import PromiseKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        showLoadingAlert(uiView: self.view)
        
        firstly {
            Api.shared.getSelectedQueue(queue: queue)
        }.then { (result) -> Void in
            self.dismissLoadingAlert(uiView: self.view)
            self.songs = self.queue.songs
            self.queuedByLabel.text = self.queue.currentSong?.userId.description
            self.currentSongLabel.text = self.queue.currentSong?.spotifyURI
            self.tableView.reloadData()
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
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        tableView.reloadData()
    }
}
