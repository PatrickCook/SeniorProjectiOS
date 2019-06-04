import ReSwift

// Error Handling and Loading Indicators
struct DisplayErrorAction: Action {
    let errorString: String?
}

struct DismissErrorAction: Action {}

struct ShowLoadingIndicatorAction: Action {}

struct DismissLoadingIndicatorAction: Action {}

// Admin Actions
struct ResetStateAction: Action {}

struct SetLoggedInUserAction: Action {
    let user: User
}

/* Fetching Queue Information */
struct FetchedJoinedQueuesAction: Action {
    let joinedQueues: [Queue]
}

struct FetchedSelectedQueueAction: Action {
    let selectedQueue: Queue
}

struct FetchedPlayingQueueAction: Action {
    let playingQueue: Queue
}

//MARK: Spotify API Actions
struct FetchedSpotifySearchResultsAction: Action {
    let spotifySearchResults: [SpotifySong]
}

struct FetchedSpotifyUserPlaylistsAction: Action {
    let spotifyUserPlaylists: [SpotifyPlaylist]
}

struct FetchedSpotifyPlaylistSongsAction: Action {
    let spotifyPlaylistSongs: [SpotifySong]
}

//MARK: Updated which Queue is being VIEWED */
struct SetSelectedQueueAction: Action {
    let selectedQueueId: Int
}

struct UpdateSelectedQueueAction: Action {
    let queue: Queue
}

/* Update which Queue is being Played */
struct SetSelectedQueueAsPlayingQueue: Action {}

struct SetPlayingQueueAction: Action {
    let playingQueue: Queue?
}

struct SetPlayingQueueToNilAction: Action {}

struct AddSongToSelectedQueueAction: Action {
    let songToAdd: Song
}

struct RemoveSongFromSelectedQueueAction: Action {
    let songId: Int
}

struct SetQueueIsPlayingAction: Action {
    let isPlaying: Bool
}

/* Queue Manipulation Actions */
struct SkipCurrentSongAction: Action {}


/* Song playback Actions */
struct MusicPlayerStateChanged: Action {}

struct UpdateCurrentSongPositionAction: Action {
    let updatedTime: Double
}

struct UpdateCurrentSongDurationAction: Action {
    let updatedDuration: Double
}

struct UpdateSliderPositionAction: Action {
    let sliderValue: Double
}

struct SetHasSliderChangedAction: Action {
    let hasSliderChanged: Bool
}
