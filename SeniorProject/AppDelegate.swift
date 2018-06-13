import UIKit
import SpotifyLogin
import ReSwift
import PusherSwift
import PromiseKit

let mainStore = Store<AppState>(
    reducer: reducer,
    state: nil
)


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let redirectURL: URL = URL(string: SpotifyCredentials.redirectURL)!
        SpotifyLogin.shared.configure(clientID: SpotifyCredentials.clientID,
                                      clientSecret: SpotifyCredentials.clientSecret,
                                      redirectURL: redirectURL)
        
        PusherUtil.shared.startPusher()
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { _ in }
        return handled
    }
}

