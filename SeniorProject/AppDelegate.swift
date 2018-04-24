import UIKit
import SpotifyLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let redirectURL: URL = URL(string: "seniorproject://")!
        SpotifyLogin.shared.configure(clientID: "579d6186a40a450a9d7f1467278f7fe1",
                                      clientSecret: "ef9e181e33254d96a6e895ee03527cac",
                                      redirectURL: redirectURL)
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { _ in }
        return handled
    }
    
}
