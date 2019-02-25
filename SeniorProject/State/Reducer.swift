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
     
    //MARK: Modify Selected Queue
    case let action as FetchedSelectedQueueAction:
        print("In Reducers - FetchedSelectedQueueAction")
        let index = state.joinedQueues.index(where: { (queue) -> Bool in
            queue.id == action.selectedQueue.id
        })
        state.joinedQueues[index!] = action.selectedQueue
        state.selectedQueue = action.selectedQueue
        
    case let action as SetSelectedQueueAction:
        print("In Reducers - SetSelectedQueueAction")
        let index = state.joinedQueues.index(where: { (queue) -> Bool in
            queue.id == action.selectedQueueId
        })
        
        state.selectedQueue = state.joinedQueues[index!]
    
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
       
    //MARK:  Modify Playing Queue
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
        MusicPlayer.shared.resetPlayback()
        state.playingQueue = nil
        state.playingSong = nil
      
    //MARK: Spotify API Reducers
        
    /* Modify Spotify Search Results */
    case let action as FetchedSpotifySearchResultsAction:
        print("In Reducers - FetchedSpotifySearchResultsAction")
        state.spotifySearchResults = action.spotifySearchResults
     
    /* Modify Spotify User Playlists */
    case let action as FetchedSpotifyUserPlaylistsAction:
        print("In Reducers - FetchedSpotifyUserPlaylistsAction")
        state.spotifyUserPlaylists = action.spotifyUserPlaylists
        
    /* Modify Spotify Playist songs */
    case let action as FetchedSpotifyPlaylistSongsAction:
        print("In Reducers - FetchedSpotifyPlaylistSongsAction")
        state.spotifyPlaylistSongs = action.spotifyPlaylistSongs
        
    //MARK: Music Player Actions
    case _ as SkipCurrentSongAction:
        print("In Reducers - SkipCurrentSongAction")

        state.playingQueue?.skip()
        
        if let nextSong = state.playingQueue?.songs.first {
            state.playingSong = nextSong
        } else {
            state.playingSong = nil
        }
        
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
    
    case _ as ResetStateAction:
        state = AppState()
    
    default:
        print("Reducer - Default Action")
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
