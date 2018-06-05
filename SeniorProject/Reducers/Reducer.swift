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
        
    case _ as SetSelectedQueueCurrentSong:
        print("In Reducers - SetSelectedQueueCurrentSong")
        state.selectedQueueCurrentSong = state.selectedQueue?.currentSong
        
    case _ as SetSelectedQueueAsPlayingQueue:
        print("In Reducers - SetSelectedQueueAsPlayingQueue")
        state.playingQueue = state.selectedQueue!
        state.playingSong = state.playingQueue.currentSong!
        
    case let action as FetchedSpotifySearchResultsAction:
        print("In Reducers - FetchedSpotifySearchResultsAction")
        state.spotifySearchResults = action.spotifySearchResults
        
    case let action as AddSongToSelectedQueueAction:
        state.selectedQueue?.enqueue(song: action.songToAdd)
        
    case _ as SkipCurrentSongAction:
        MusicPlayer.shared.skip()
        
    case _ as RestartCurrentSongAction:
        MusicPlayer.shared.restart()
        
    case _ as ToggleCurrentSongAction:
        MusicPlayer.shared.togglePlayback()
    
    default:
        break
    }
    
    //printState(state: state)
    
    return state
}

func printState(state: AppState) {
    print("------------ Printing State ------------")
    
    print("Joined Queues:")
    for queue in state.joinedQueues {
        print(queue.description)
    }
    
    print("\nSelected Queue:")
    print(state.selectedQueue?.description ?? "No selected queue.")
    
    print("\nSelected Queue Current Song:")
    print(state.selectedQueueCurrentSong?.description ?? "No current song.")
    
    print("\nPlaying Queue:")
    print(state.playingQueue.description)
    
    print("\nPlaying Song:")
    print(state.playingSong.description)
    
    print("---------------------------------------")
}
