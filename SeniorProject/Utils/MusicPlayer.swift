import Foundation
import SpotifyLogin
import AVFoundation

class MusicPlayer: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    static let shared: MusicPlayer = MusicPlayer()
    
    var isPreviewPlaying = false
    var audioStream: AVAudioPlayer
    var player: SPTAudioStreamingController?
    var playback: PlaybackState = .INIT
    
    enum PlaybackState {
        case INIT, PLAYING, PAUSED
    }
    
    override init() {
        audioStream = AVAudioPlayer()
        super.init()
        
        player = SPTAudioStreamingController.sharedInstance()
        player?.playbackDelegate = self
        player?.delegate = self
        try! player?.start(withClientId: SpotifyCredentials.clientID)
    }
    
    func togglePlayback() {
        switch (playback) {
        case .INIT:
            print("MusicPlayer: INIT -> PLAYING")
            initPlayback()
        case .PLAYING:
            print("MusicPlayer: PLAYING -> PAUSED")
            pausePlayback()
        case .PAUSED:
            print("MusicPlayer: PAUSED -> PLAYING")
            playPlayback()
        default:
            print("Music Player: ERROR STATE")
        }
    }
    
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
        
        playPlayback()
    }
    
    /* PLAY BUTTON STATE METHODS */
    
    func initPlayback() {
        let queue = mainStore.state.playingQueue
        
        if (queue.songs.count > 0) {
            let songURL = queue.songs.first?.spotifyURI
            player!.playSpotifyURI(songURL, startingWith: 0, startingWithPosition: 0, callback: { error in
                if error != nil {
                    print("*** failed to play: \(error)")
                    return
                } else {
                    self.playback = .PLAYING
                }
            })
        }
    }
    
    func playPlayback() {
        player?.setIsPlaying(true, callback: nil)
        playback = .PLAYING
    }
    
    func pausePlayback() {
        player?.setIsPlaying(false, callback: nil)
        playback = .PAUSED
    }
    
    func restart() {
        initPlayback()
    }
    
    func skip() {
        mainStore.state.playingQueue.dequeue()
        initPlayback()
    }

    /*  SPOTIFY DELEGATE METHODS */
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: .AVAudioSessionInterruption,
                                       object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            print("Music Player: Interuption begain")
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
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
        try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try? session.setActive(true)
    }
    
    
    // MARK: Deactivate audio session
    
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Music Player - Audio Streaming Error: \(error)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("Music Player - Move to next Song")
        mainStore.dispatch(SkipCurrentSongAction())
    }
    
}
