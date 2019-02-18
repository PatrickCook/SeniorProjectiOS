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
    @IBOutlet weak var playbackButton: UIButton!
    
    @IBAction func togglePlayback(_ sender: Any) {
        MusicPlayer.shared.togglePlayback()
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
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        
        mainStore.subscribe(self)
    }
    
    func newState(state: AppState) {
        let newImage: UIImage
        let userId = state.loggedInUser?.id
        let isPlaying = state.playingQueue?.isPlaying ?? false
        let playingUserId = state.playingQueue?.playingUserId ?? 0
        
        if (MusicPlayer.shared.isPlaying) {
            newImage = pauseButton!
        } else {
            newImage = playButton!
        }
        
        if (isPlaying && (playingUserId == userId)) {
            playbackButton.isHidden = false;
        } else {
            playbackButton.isHidden = true;
        }
        
        songNameLabel.text = "-- • --"
        queueNameLabel.text = "--"
        
        if let songName = state.playingSong?.title,
            let artistName = state.playingSong?.artist,
            let queueName = state.playingQueue?.name  {
            
            songNameLabel.text = "\(songName) • \(artistName)"
            queueNameLabel.text = queueName
        }
        
        playbackButton.setImage(newImage, for: UIControl.State.normal)
    }
}
