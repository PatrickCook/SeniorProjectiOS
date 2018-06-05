import ReSwift

struct AppState: StateType {
    var spotifySearchResults: [SpotifySong] = []
    var joinedQueues: [Queue] = []
    var selectedQueue: Queue?
    var selectedQueueCurrentSong: Song?
    var playingQueue: Queue = Queue()
    var playingSong: Song = Song()
}

