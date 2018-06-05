import Foundation
import SpotifyLogin
import AVFoundation

class MusicPlayer: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    static let shared: MusicPlayer = MusicPlayer()
    
    var isPreviewPlaying = false
    var isPlaying = false
    var audioStream: AVAudioPlayer
    var player: SPTAudioStreamingController?
    
    override init() {
        audioStream = AVAudioPlayer()
        super.init()
        
        player = SPTAudioStreamingController.sharedInstance()
        player?.playbackDelegate = self
        player?.delegate = self
        try! player?.start(withClientId: SpotifyCredentials.clientID)
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
         print("Successful Login")
        player!.playSpotifyURI("spotify:track:7jZHUhAmW5oq1cq6s8IxmK", startingWith: 0, startingWithPosition: 0, callback: { error in
            if error != nil {
                print("*** failed to play: \(error)")
                return
            } else {
                print("play")
            }
        })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Music Player - Audio Streaming Error: \(error)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("Music Player - No idea what this does")
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
        isPreviewPlaying = !isPreviewPlaying
        if (audioStream.isPlaying) {
            audioStream.pause()
        }
    }
    
    func togglePlayback () {
        isPlaying = !isPlaying
        print("Music Player is \(isPlaying ? "playing" : "paused")")
    }
    
    func skip() {
        print("Music Player - Skip song")
    }
    
    /*
     * NOT_LOADED_PLAY_PRESSED
     * LOADED_PLAY_PRESSED - was paused
     */
    func play() {
        print("Music Player - Play song")
    }
    
    /*  LOADED_PAUSE - was playing */
    func pause() {
        print("Music Player - Pause song")
    }
    
    func restart() {
        print("Music Player - Restart Song")
    }
    
//
//    LOADED_PAUSE - was playing
//    EMPTY_QUEUE
    
    
}
