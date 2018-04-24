
import UIKit
import SpotifyLogin

class ViewController: UIViewController {
    
    @IBOutlet weak var loggedInStackView: UIStackView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            self?.loggedInStackView.alpha = (error == nil) ? 1.0 : 0.0
            if error != nil, token == nil {
                self?.showLoginFlow()
            }
        }
    }
    
    func showLoginFlow() {

        self.performSegue(withIdentifier: "home_to_login", sender: self)
    }
    
    @IBAction func didTapLogOut(_ sender: Any) {
        SpotifyLogin.shared.logout()
        self.loggedInStackView.alpha = 0.0
        self.showLoginFlow()
    }
    
}
