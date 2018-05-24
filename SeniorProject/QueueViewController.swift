
import UIKit
import SpotifyLogin
import PromiseKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
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

        initializeData()
        
        resumeQueueButton.layer.cornerRadius = 20
        resumeQueueButton.clipsToBounds = true
    }
    
    
    func initializeData() {
        showLoadingAlert(uiView: self.view)
        
        firstly {
            Api.shared.getSelectedQueue(queue: queue)
        }.then { (result) -> Void in
            self.dismissLoadingAlert(uiView: self.view)
            self.songs = self.queue.songs
            self.queuedByLabel.text = self.queue.currentSong?.userId.description
            self.currentSongLabel.text = self.queue.currentSong?.title
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
        
        songCell?.song = songs[indexPath.row]
        songCell?.songNameLabel.text = songs[indexPath.row].title
        songCell?.queuedByLabel.text = "\(songs[indexPath.row].userId)"
        songCell?.votesLabel.text = "\(songs[indexPath.row].votes)"
        
        return songCell!
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Next up:"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        headerView.backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
        
        let headerLabel = UILabel(frame: CGRect(x: 25, y: 0, width:
            tableView.bounds.size.width, height:30))

        headerLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        headerLabel.text = "Next Up"
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
