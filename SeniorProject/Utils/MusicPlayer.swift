import Foundation
import SpotifyLogin
import AVFoundation

class MusicPlayer {
    static let shared: MusicPlayer = MusicPlayer()
    var player: SPTAudioStreamingController?
    var isPreviewPlaying = false
    var isPlaying = false
    var audioStream: AVAudioPlayer
    
    init() {
        audioStream = AVAudioPlayer()
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
