//
//  MusicPlayerUIView.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/15/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit
import ReSwift

class MiniMusicPlayerView: UIView, StoreSubscriber {
    var isPlaying: Bool = false
    var nibName = "MiniMusicPlayerView"
    var playButton = UIImage(named: "play-icon")
    var pauseButton = UIImage(named: "pause-icon")
    var view: UIView!
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var queueNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var playbackButton: UIButton!
    
    @IBAction func togglePlayback(_ sender: Any) {
        mainStore.dispatch(TogglePlaybackAction())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetUp()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        
        mainStore.subscribe(self)
    }
    
    func newState(state: AppState) {
        let newImage: UIImage
        let userId = state.loggedInUser?.id
        let isPlaying = state.playingQueue.isPlaying
        let playingUserId = state.playingQueue.playingUserId
        
        if (MusicPlayer.shared.playback == .PLAYING) {
            newImage = pauseButton!
        } else {
            newImage = playButton!
        }
        
        print("MiniMusicPlayer - isPlaying: \(isPlaying), playingUseId: \(playingUserId), loggedInUser: \(userId)")
        if (isPlaying && playingUserId == userId) {
            playbackButton.isHidden = false;
        } else {
            playbackButton.isHidden = true;
        }
        
        songNameLabel.text = state.playingSong.title
        queueNameLabel.text =  state.playingQueue.name
        artistNameLabel.text = state.playingSong.artist
        playbackButton.setImage(newImage, for: UIControlState.normal)
    }
}
