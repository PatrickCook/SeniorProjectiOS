import Foundation
import SpotifyLogin
import AVFoundation
import PromiseKit
import MediaPlayer


class MusicPlayer: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    static let shared: MusicPlayer = MusicPlayer()
    
    var audioStream: AVAudioPlayer = AVAudioPlayer()
    var player: SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    
    var isPlaying: Bool {
        return playback == .PLAYING
    }
    
    var isPreviewPlaying = false
    
    private var playback: PlaybackState = .INIT
    
    enum PlaybackState {
        case INIT, PLAYING, PAUSED, ERROR
    }
    
    private override init() {
        super.init()
        
        player.playbackDelegate = self
        player.delegate = self
        
        try! player.start(withClientId: SpotifyCredentials.clientID)
        
        activateAudioSession()
        setupNotifications()
        setupRemoteCommandCenter()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        deactivateAudioSession()
        try? player.stop()
    }
    
    func togglePlayback() {
        switch (playback) {
        case .INIT:
            print("MusicPlayer: INIT -> PLAYING")
            startPlayback()
        case .PLAYING:
            print("MusicPlayer: PLAYING -> PAUSED")
            pausePlayback()
        case .PAUSED:
            print("MusicPlayer: PAUSED -> PLAYING")
            resumePlayback()
        case .ERROR:
            print("MusicPlayer: ERROR")
        }
    }
    
    // MARK: Music Player playback methods
    
    func startPlayback() {
        guard let queue = mainStore.state.playingQueue else {
            print("MusicPlayer: Cannot start playback without a song")
            return
        }
        
        guard let song = queue.songs.first else {
            print("MusicPlayer: Cannot start playback when the queue is empty")
            return
        }
        
        self.playback = .PLAYING
        song.setIsPlaying(true)
        
        player.playSpotifyURI(song.spotifyURI, startingWith: 0, startingWithPosition: 0, callback: { error in
            if error != nil {
                print("MusicPlayer: \(String(describing: error))")
                self.playback = .ERROR
                return
            } else {
                mainStore.dispatch(MusicPlayerStateChanged())
                mainStore.dispatch(UpdateCurrentSongPositionAction(updatedTime: 0.0))
                self.updateNowPlaying()
            }
        })
    }
    
    func resumePlayback() {
        player.setIsPlaying(true, callback: nil)
        MPNowPlayingInfoCenter.default().playbackState = .playing
        playback = .PLAYING
        mainStore.dispatch(MusicPlayerStateChanged())
    }
    
    func pausePlayback() {
        player.setIsPlaying(false, callback: nil)
        MPNowPlayingInfoCenter.default().playbackState = .paused
        playback = .PAUSED
        mainStore.dispatch(MusicPlayerStateChanged())
    }
    
    func resetPlayback() {
        MPNowPlayingInfoCenter.default().playbackState = .stopped
        playback = .INIT
    }
    
    func skip() {
        
        guard let playingQueue = mainStore.state.playingQueue, let playingSong = mainStore.state.playingSong else {
            print("MusicPlayer: Cannot skip without playing queue or song")
            return
        }
        
        Api.shared.dequeueSong(queueId: playingQueue.id, songId: playingSong.id)
            .catch { (error) in
                print("ERROR: MusicPlayer.skip()")
        }
        
        mainStore.dispatch(SkipCurrentSongAction())
        
        resetPlayback()
        
        // Is there another song to play? If not set queue to not playing anymore
        if let _ = mainStore.state.playingSong {
            togglePlayback()
        } else {
            Api.shared.setQueueIsPlaying(queueId: playingQueue.id, isPlaying: false)
        }
    }
    
    func seektoCurrentTime(timeValue: Double){
        player.seek(to: timeValue, callback: { error in
            if error != nil {
                print("*** failed to play: \(String(describing: error))")
                return
            } else {
                self.playback = .PLAYING
            }
        })
    }
    
    // MARK:  Preview Handler Methods
    
    func downloadAndPlayPreviewURL(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            self.playPreviewURL(url: customURL!)
        })
        downloadTask.resume()
    }
    
    func playPreviewURL(url: URL) {
        pausePlayback()
        isPreviewPlaying = !isPreviewPlaying
        do {
            audioStream = try AVAudioPlayer(contentsOf: url)
            audioStream.prepareToPlay()
            audioStream.play()
        } catch {
            print(error)
        }
    }
    
    func stopPreviewURL() {
        if (isPreviewPlaying) {
            isPreviewPlaying = !isPreviewPlaying
            audioStream.pause()
        }
    }
    
    // MARK: Music Player Info center setup
    
    func updateNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        
        let imageURL = URL(string: (mainStore.state.playingSong?.imageURI)!)
        let imageData = NSData(contentsOf: imageURL!)
        let image = UIImage(data: imageData! as Data)!
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = mainStore.state.playingSong?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = mainStore.state.playingSong?.artist
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = mainStore.state.playingSongCurrentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = mainStore.state.playingSongDuration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.togglePlayback()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.togglePlayback()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { event in
            self.skip()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { event in
            self.startPlayback()
            return .success
        }
    }
    

    // MARK: Audio Session setup methods
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            print("Music Player: Interuption begain")
            pausePlayback()
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    print("Music Player: Interruption - playback should resume")
                    resumePlayback()
                } else {
                    // Interruption Ended - playback should NOT resume
                    print("Music Player: Interruption - playback should NOT resume")
                    resetPlayback()
                }
            }
        }
    }
    
    
    
    // MARK: Activate audio session
    
    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowAirPlay)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting the AVAudioSession:", error.localizedDescription)
        }
    }
    
    
    // MARK: Deactivate audio session
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: Spotify Delegate Methods
    
    /* Changing playback status */
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        
    }
    
    /* Change song position */
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        
        if (!mainStore.state.hasSliderChanged) {
            mainStore.dispatch(UpdateCurrentSongPositionAction(updatedTime: position))
        }
    }
    
    /* song metadata changed */
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        mainStore.dispatch(UpdateCurrentSongDurationAction(updatedDuration: (metadata.currentTrack?.duration)!))
    }
    
    /* received audio error */
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Music Player - Audio Streaming Error")
    }
    
    /* Playback stopped from track ending */
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        skip()
    }
    
    
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
