
import UIKit
import SpotifyLogin

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /* Segue in order to search for songs */
    @IBAction func addSongSegue(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "moveToSearch", sender: self)
    }
    
    
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
        
        songCell?.songNameLabel.text = "Default Song Name"
        songCell?.queuedByLabel.text = "default_user"
        songCell?.votesLabel.text = "0"
        
        return songCell!
    }
}
