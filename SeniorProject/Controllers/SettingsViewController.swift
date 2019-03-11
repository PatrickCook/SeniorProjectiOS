//
//  SettingsViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/20/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//

import Foundation
import SpotifyLogin



class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @IBAction func goBackToJoinedQueues(_ sender: Any) {
        performSegue(withIdentifier: "unwindSequeToJoinedQueues", sender: self)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try AuthController.signOut()
            SpotifyLogin.shared.logout()
            
            if let playingQueue = mainStore.state.playingQueue {
                MusicPlayer.shared.pausePlayback()
                Api.shared.setQueueIsPlaying(queueId: playingQueue.id, isPlaying: false)
            }
            
            mainStore.dispatch(ResetStateAction())
            
            performSegue(withIdentifier: "unwindSequeToJoinedQueues", sender: self)
        } catch {
            print("error occured while signing out")
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
