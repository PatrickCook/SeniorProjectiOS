import ReSwift

struct AppState: StateType {
    var loggedInUser: User?
    var spotifySearchResults: [SpotifySong] = []
    var spotifyUserPlaylists: [SpotifyPlaylist] = []
    var joinedQueues: [Queue] = []
    var selectedQueue: Queue?
    var selectedQueueCurrentSong: Song?
    var playingQueue: Queue?
    var playingSong: Song?
    var playingSongCurrentTime: Double = 0.0
    var playingSongDuration: Double = 0.0
    var hasSliderChanged: Bool = false
}

