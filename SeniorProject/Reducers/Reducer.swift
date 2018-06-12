import ReSwift

func reducer(action: Action, state: AppState?) -> AppState {
    // if no state has been provided, create the default state
    var state = state ?? AppState()
    
    switch action {
    case let action as SetLoggedInUserAction:
        state.loggedInUser = action.user
        
    case let action as FetchedJoinedQueuesAction:
        print("In Reducers - Fetched Joined Queues Action")
        state.joinedQueues = action.joinedQueues
     
    /* Modify Selected Queue */
    case let action as FetchedSelectedQueueAction:
        print("In Reducers - FetchedSelectedQueueAction")
        state.selectedQueue = action.selectedQueue
        
    case let action as SetSelectedQueueAction:
        print("In Reducers - SetSelectedQueueAction")
        state.selectedQueue = action.selectedQueue
    
    case let action as AddSongToSelectedQueueAction:
        print("In Reducers - AddSongToSelectedQueueAction")
        state.selectedQueue?.enqueue(song: action.songToAdd)
    
    case let action as UpdateSelectedQueueAction:
        print("In Reducers - UpdateQueueAction")
        state.selectedQueue = action.queue
        state.joinedQueues = state.joinedQueues.map {
            return $0.id == action.queue.id ? action.queue : $0
        }
        
    case let action as RemoveSongFromSelectedQueueAction:
        state.selectedQueue!.songs = state.selectedQueue!.songs.filter { $0.id != action.songId }
       
    /* Modify Playing Queue */
    case let action as FetchedPlayingQueueAction:
        print("In Reducers - FetchedPlayingQueueAction")
        state.playingQueue = action.playingQueue
        
    case _ as SetSelectedQueueAsPlayingQueue:
        print("In Reducers - SetSelectedQueueAsPlayingQueue")
        state.playingQueue = state.selectedQueue!
        if (state.playingQueue!.songs.count > 0) {
            state.playingSong = state.playingQueue!.songs.first
        }
        
    case _ as SetPlayingQueueToNilAction:
        print("In Reducers - SetPlayingQueueToNilAction")
        MusicPlayer.shared.playback = .INIT
        state.playingQueue = nil
        state.playingSong = nil
      
    /* Modify Spotify Search Results */
    case let action as FetchedSpotifySearchResultsAction:
        print("In Reducers - FetchedSpotifySearchResultsAction")
        state.spotifySearchResults = action.spotifySearchResults
        
    /* Music Player Actions */
    case _ as SkipCurrentSongAction:
        print("In Reducers - SkipCurrentSongAction")
        MusicPlayer.shared.skip()
        MusicPlayer.shared.playback = .INIT
        if (state.playingQueue!.songs.count > 0) {
            state.playingSong = state.playingQueue!.songs.first
            MusicPlayer.shared.togglePlayback()
        }
        
    case _ as RestartCurrentSongAction:
        MusicPlayer.shared.restart()
        
    case _ as TogglePlaybackAction:
        MusicPlayer.shared.togglePlayback()
        
    case _ as StopPlaybackAction:
        MusicPlayer.shared.pausePlayback()
        
    case _ as ResetMusicPlayerStateAction:
        MusicPlayer.shared.playback = .INIT
        
    /* Playing Song Action */
    case let action as UpdateCurrentSongPositionAction:
        state.playingSongCurrentTime = action.updatedTime
    
    case let action as UpdateCurrentSongDurationAction:
        state.playingSongDuration = action.updatedDuration
        
    case let action as UpdateSliderPositionAction:
        state.playingSongCurrentTime = (action.sliderValue/100) * state.playingSongDuration
        MusicPlayer.shared.seektoCurrentTime(timeValue: state.playingSongCurrentTime)
        
    case let action as SetHasSliderChangedAction:
        state.hasSliderChanged = action.hasSliderChanged
        
    default:
        print("Reducer - Unexpected Action")
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
    print(state.playingQueue?.description ?? "Not set")
    
    print("\nPlaying Song:")
    print(state.playingSong?.description ?? "Not set")
    
    print("---------------------------------------")
}
