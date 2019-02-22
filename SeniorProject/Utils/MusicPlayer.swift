import Foundation
import SpotifyLogin
import AVFoundation
import PromiseKit

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
    
    override init() {
        super.init()
        
        player.playbackDelegate = self
        player.delegate = self
        try! player.start(withClientId: SpotifyCredentials.clientID)
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
    
    /* PLAY BUTTON STATE METHODS */
    
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
        
        player.playSpotifyURI(song.spotifyURI, startingWith: 0, startingWithPosition: 0, callback: { error in
            if error != nil {
                print("MusicPlayer: \(String(describing: error))")
                self.playback = .ERROR
                return
            } else {
                mainStore.dispatch(MusicPlayerStateChanged())
                mainStore.dispatch(UpdateCurrentSongPositionAction(updatedTime: 0.0))
            }
        })
    }
    
    func resumePlayback() {
        player.setIsPlaying(true, callback: nil)
        playback = .PLAYING
        mainStore.dispatch(MusicPlayerStateChanged())
    }
    
    func pausePlayback() {
        player.setIsPlaying(false, callback: nil)
        playback = .PAUSED
        mainStore.dispatch(MusicPlayerStateChanged())
    }
    
    func resetPlayback() {
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
    
    /* Preview Handler Methods */
    
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
    

    /*  SPOTIFY DELEGATE METHODS */
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
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    print("Music Player: Interruption - playback should resume")
                } else {
                    // Interruption Ended - playback should NOT resume
                    print("Music Player: Interruption - playback should NOT resume")
                }
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            self.activateAudioSession()
        } else {
           // self.deactivateAudioSession()
        }
    }
    
    // MARK: Activate audio session
    
    func activateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default)
        try? session.setActive(true)
    }
    
    
    // MARK: Deactivate audio session
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        
        if (!mainStore.state.hasSliderChanged) {
            mainStore.dispatch(UpdateCurrentSongPositionAction(updatedTime: position))
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        mainStore.dispatch(UpdateCurrentSongDurationAction(updatedDuration: (metadata.currentTrack?.duration)!))
    }
    
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Music Player - Audio Streaming Error")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        skip()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
