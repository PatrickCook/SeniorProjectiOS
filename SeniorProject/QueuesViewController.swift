
import UIKit
import SpotifyLogin

class QueuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                self?.showLoginFlow()
            }
        }
        
        self.tableView.reloadData()
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let queueCell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueCell
        
        queueCell?.queueNameLabel.text = "DEFAULT QUEUE NAME"
        queueCell?.currentSongLabel.text = "DEFAULT SONG LABEL"
        
        return queueCell!
    }
    
    
    
    /* Helpers */
    func showLoginFlow() {
        self.performSegue(withIdentifier: "home_to_login", sender: self)
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        SpotifyLogin.shared.logout()
        self.showLoginFlow()
    }
}
