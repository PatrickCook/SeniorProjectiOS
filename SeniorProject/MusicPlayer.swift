import Foundation
import SpotifyLogin
import AVFoundation

class MusicPlayer {
    static let shared: MusicPlayer = MusicPlayer()
    
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
        do {
            audioStream = try AVAudioPlayer(contentsOf: url)
            audioStream.prepareToPlay()
            audioStream.play()
        } catch {
            print(error)
        }
    }
    
    func stopPreviewURL() {
        if (audioStream.isPlaying) {
            audioStream.pause()
        }
    }
}
