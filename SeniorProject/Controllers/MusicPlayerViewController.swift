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
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        if (mainStore.state.playingSong != nil) {
            let url = URL(string: (mainStore.state.playingSong?.spotifyURI)!)!
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
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
        guard let _ = mainStore.state.playingQueue else {
            print("There is no playing queue")
            return
        }
        MusicPlayer.shared.togglePlayback()
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        guard let _ = mainStore.state.playingQueue else {
            print("There is no playing queue")
            return
        }
        MusicPlayer.shared.startPlayback()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let _ = mainStore.state.playingQueue else {
            print("There is no playing queue")
            return
        }
        MusicPlayer.shared.skip()
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
        
        let newImage: UIImage
        
        if state.playingSong == nil {
            initMusicPlayerViewToDefault(state: state)
            return
        }
        
        let url = URL(string: state.playingSong!.imageURI)!
        queueNameLabel.text = state.playingQueue!.name
        songNameLabel.text = state.playingSong!.title
        artistNameLabel.text = state.playingSong!.artist
        
        // Change this as state changes...?
        musicSlider.value = Float(state.playingSongCurrentTime/state.playingSongDuration) * 100
        
        albumImage.kf.indicatorType = .activity
        albumImage.kf.setImage(with: url, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image == nil) {
                self.albumImage.image = UIImage(named: "default-album-cover")    
            }
        })
        
        if (MusicPlayer.shared.isPlaying) {
            newImage = pauseButton!
        } else {
            newImage = playButton!
        }
        
        currentTimeLabel.text = ConversionUtilities.shared.convertTimeInSecondsToString(seconds: state.playingSongCurrentTime)
        timeRemainingLabel.text = ConversionUtilities.shared.convertTimeInSecondsToString(seconds:state.playingSongDuration - state.playingSongCurrentTime)
        playbackButton.setImage(newImage, for: UIControl.State.normal)
    }
    
    func initMusicPlayerViewToDefault (state: AppState) {
        queueNameLabel.text = "--"
        songNameLabel.text = "--"
        artistNameLabel.text = "--"
        albumImage.image = UIImage(named: "default-album-cover")
        
        currentTimeLabel.text = "0:00"
        timeRemainingLabel.text = "0:00"
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
