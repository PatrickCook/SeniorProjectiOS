import ReSwift

// all of the actions that can be applied to the state
struct FetchedJoinedQueuesAction: Action {
    let joinedQueues: [Queue]
}

struct FetchedSelectedQueueAction: Action {
    let selectedQueue: Queue
}

struct SetSelectedQueueAction: Action {
    let selectedQueue: Queue
}

struct SetSelectedQueueAsPlayingQueue: Action {}

struct FetchedSpotifySearchResultsAction: Action {
    let spotifySearchResults: [SpotifySong]
}

struct AddSongToSelectedQueueAction: Action {
    let songToAdd: Song
}

struct RestartCurrentSongAction: Action {}

struct SkipCurrentSongAction: Action {}

struct TogglePlaybackAction: Action {}
