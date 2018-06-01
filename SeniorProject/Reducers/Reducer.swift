import ReSwift

func reducer(action: Action, state: AppState?) -> AppState {
    // if no state has been provided, create the default state
    var state = state ?? AppState()
    
    switch action {
    case let action as FetchedJoinedQueuesAction:
        print("In Reducers - Fetched Joined Queues Action")
        state.joinedQueues = action.joinedQueues
        
    case let action as FetchedSelectedQueueAction:
        print("In Reducers - FetchedSelectedQueueAction")
        state.selectedQueue = action.selectedQueue
        
    case let action as SetSelectedQueueAction:
        print("In Reducers - SetSelectedQueueAction")
        state.selectedQueue = action.selectedQueue
        
    case let action as SetSelectedQueueCurrentSong:
        state.selectedQueueCurrentSong = state.selectedQueue?.currentSong
        
    case let action as FetchedSpotifySearchResultsAction:
        print("In Reducers - FetchedSpotifySearchResultsAction")
        state.spotifySearchResults = action.spotifySearchResults
        
    case let action as AddSongToSelectedQueueAction:
        state.selectedQueue?.enqueue(song: action.songToAdd)
        
    case _ as SkipCurrentSongAction:
        MusicPlayer.shared.skip()
        
    case _ as PlayCurrentSongAction:
        MusicPlayer.shared.play()
        
    case _ as PauseCurrentSongAction:
        MusicPlayer.shared.pause()
        
    default:
        break
    }
    
    return state
}
