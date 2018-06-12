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
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        print("Plus button tapped")
        let url = URL(string: (mainStore.state.playingSong?.spotifyURI)!)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func moreButtonTapped(_ sender: Any) {
        
    }
    // TODO: Need to update state to obtain song length
    // Right now this will fail if song over 3:00 is played
    // and you toggle over it
    
    @IBAction func finishEditingSlider(_ sender: Any) {
        mainStore.dispatch(SetHasSliderChangedAction(hasSliderChanged: false))
    }
    @IBAction func startEditingSlider(_ sender: Any) {
        mainStore.dispatch(SetHasSliderChangedAction(hasSliderChanged: true))
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        mainStore.dispatch(UpdateSliderPositionAction(sliderValue: Double(musicSlider.value)))
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
        mainStore.subscribe(self)
        musicSlider.isContinuous = false
        musicSlider.setThumbImage(UIImage(named:"sliderThumb"), for: .normal)
    }
    
    func newState(state: AppState) {
        let url = URL(string: (state.playingSong?.imageURI)!)!
        let newImage: UIImage
        
        queueNameLabel.text = state.playingQueue?.name ?? "--"
        songNameLabel.text = state.playingSong?.title ?? "--"
        artistNameLabel.text = state.playingSong?.artist ?? "--"
        
        // Change this as state changes...?
        musicSlider.value = Float(state.playingSongCurrentTime/state.playingSongDuration) * 100
        
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
        
        currentTimeLabel.text = Utils.shared.convertTimeInSecondsToString(seconds: state.playingSongCurrentTime)
        timeRemainingLabel.text = Utils.shared.convertTimeInSecondsToString(seconds:state.playingSongDuration - state.playingSongCurrentTime)
        playbackButton.setImage(newImage, for: UIControlState.normal)
    }
}
