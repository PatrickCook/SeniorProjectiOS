import ReSwift

//struct AppState: StateType {
//    var spotifySearchResults: [Song] = []
//    var joinedQueues: [Queue] = []
//    var selectedQueue: Queue
//    var playingQueue: Queue
//    var currentSong: Song
//}

func reducer(action: Action, state: AppState?) -> AppState {
    // if no state has been provided, create the default state
    var state = state ?? AppState()
    
    switch action {
    case let action as FetchedJoinedQueuesAction:
        state.joinedQueues = action.joinedQueues
    case let action as FetchedSelectedQueueAction:
        state.selectedQueue = action.selectedQueue
    case let action as FetchedSpotifySearchResultsAction:
        state.spotifySearchResults = action.spotifySearchResults
    case let action as AddSongToSelectedQueueAction:
        state.selectedQueue?.enqueue(song: action.songToAdd)
    case let _ as SkipCurrentSongAction:
        MusicPlayer.shared.skip()
    case let _ as PlayCurrentSongAction:
        MusicPlayer.shared.play()
    case let _ as PauseCurrentSongAction:
        MusicPlayer.shared.pause()
    default:
        break
    }
    
    return state
}
