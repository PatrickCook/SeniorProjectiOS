import ReSwift

struct AppState: StateType {
    var spotifySearchResults: [SpotifySong] = []
    var joinedQueues: [Queue] = []
    var selectedQueue: Queue?
    var playingQueue: Queue?
    var currentSong: Song?
}
