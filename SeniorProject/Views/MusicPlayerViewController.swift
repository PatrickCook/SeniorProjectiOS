//
//  MusicPlayerViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/15/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit
import ReSwift
import Kingfisher

class MusicPlayerViewController: UIViewController, StoreSubscriber {
    
    var playButton = UIImage(named: "play-icon")
    var pauseButton = UIImage(named: "pause-icon")
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var playbackButton: UIButton!
    
    @IBAction func playbackToggleTapped(_ sender: Any) {
        mainStore.dispatch(ToggleCurrentSongAction())
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        mainStore.dispatch(RestartCurrentSongAction())
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        mainStore.dispatch(SkipCurrentSongAction())
    }
    
    @IBAction func closeMusicPlayerSwiped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeMusicPlayerTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainStore.subscribe(self)
        
        playbackButton.setImage(MusicPlayer.shared.isPlaying ? playButton : pauseButton, for: UIControlState.normal)
    }
    
    func newState(state: AppState) {
        let url = URL(string: state.playingSong.imageURI)!
        
        songNameLabel.text = state.playingSong.title
        artistNameLabel.text = state.playingSong.artist
        
        albumImage.kf.indicatorType = .activity
        albumImage.kf.setImage(with: url, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image == nil) {
                self.albumImage.image = UIImage(named: "default-album-cover")    
            }
        })
        
        playbackButton.setImage(MusicPlayer.shared.isPlaying ? pauseButton : playButton, for: UIControlState.normal)
    }
}
