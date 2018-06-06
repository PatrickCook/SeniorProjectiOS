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
    
    @IBOutlet weak var queueNameLabel: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    
    // TODO: Need to update state to obtain song length
    // Right now this will fail if song over 3:00 is played
    // and you toggle over it
    @IBAction func sliderToggled(_ sender: Any) {
        //TODO: set maximum of musicSlider here
        musicSlider.isContinuous = false
        print(musicSlider.value)
        MusicPlayer.shared.toggleSlider(value: musicSlider.value)
    }
    
    
    @IBAction func playbackToggleTapped(_ sender: Any) {
        mainStore.dispatch(TogglePlaybackAction())
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
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        mainStore.subscribe(self)
    }
    
    @objc func updateSlider() {
        musicSlider.value = Float((MusicPlayer.shared.player?.playbackState.position)!)
    }
    
    func newState(state: AppState) {
        let url = URL(string: state.playingSong.imageURI)!
        let newImage: UIImage
        
        queueNameLabel.text = state.playingQueue.name
        songNameLabel.text = state.playingSong.title
        artistNameLabel.text = state.playingSong.artist
        // Change this as state changes...?
        musicSlider.maximumValue = 180.0
        musicSlider.value = Float((MusicPlayer.shared.player?.playbackState.position)!)
        
        albumImage.kf.indicatorType = .activity
        albumImage.kf.setImage(with: url, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image == nil) {
                self.albumImage.image = UIImage(named: "default-album-cover")    
            }
        })
        
        if (MusicPlayer.shared.playback == .PLAYING) {
            newImage = pauseButton!
        } else {
            newImage = playButton!
        }
        
        playbackButton.setImage(newImage, for: UIControlState.normal)
    }
}
