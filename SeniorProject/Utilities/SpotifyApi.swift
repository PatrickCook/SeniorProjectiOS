//
//  SpotifyApi.swift
//  SeniorProject
//
//  Created by Patrick Cook on 3/7/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit
import SpotifyLogin

class SpotifyApi {
    
    static let shared: SpotifyApi = SpotifyApi()

    var sessionManager: SessionManager
    var pagedSongs: [SpotifySong] = []
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4 // seconds
        configuration.timeoutIntervalForResource = 4
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    
    //MARK: Spotify API Requests
    
    func search(query: String, spotifyToken: String) -> Promise<[SpotifySong]> {
        let modifiedWord = query.replacingOccurrences(of: " ", with: "+")
        let searchURL = "https://api.spotify.com/v1/search?q=\(modifiedWord)&type=track"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(spotifyToken)"]
        
        return Promise { fulfill, reject in
            sessionManager.request(searchURL, headers: headers)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let tracks = json["tracks"]
                        
                        if let items = tracks["items"].array {
                            var songs: [SpotifySong] = []
                            for item in items {
                                guard item.dictionaryObject != nil else {
                                    continue
                                }
                                let title = item["name"].stringValue
                                let artist = item["album"]["artists"][0]["name"].stringValue
                                let previewURI: String
                                let songURI = item["uri"].stringValue
                                let albumURI = item["album"]["images"][0]["url"].stringValue
                                
                                if (item["preview_url"] == JSON.null) {
                                    previewURI = "null"
                                } else {
                                    previewURI = item["preview_url"].stringValue
                                }
                                
                                let song = SpotifySong(data: ["title": title, "artist": artist, "album_uri": albumURI, "spotify_uri": songURI, "preview_uri": previewURI])
                                
                                songs.append(song!)
                            }
                            fulfill(songs)
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func fetchPlaylistSongs(playlistID: String, spotifyToken: String) -> Promise<[SpotifySong]> {
        let query = "https://api.spotify.com/v1/playlists/\(playlistID)/tracks"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(spotifyToken)"]
        
        pagedSongs.removeAll()
        
        return Promise { fulfill, reject in
            fetchPlaylistSongsHelper(query: query, headers: headers)
                .then { results in
                    fulfill(self.pagedSongs)
                }.catch { error in
                    reject(error)
                }
            
        }
    }
    
    func fetchPlaylistSongsHelper(query: String, headers: HTTPHeaders) -> Promise<[SpotifySong]> {
        
        return Promise { fulfill, reject in
            sessionManager.request(query, headers: headers)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        
                        if let items = json["items"].array {
                            for item in items {
                                let preview_uri: String
                                
                                if item["track"]["preview_url"] == JSON.null {
                                    preview_uri = "null"
                                } else {
                                    preview_uri = item["track"]["preview_url"].stringValue
                                }
                                
                                let song = SpotifySong(data: [
                                    "title": item["track"]["name"].stringValue,
                                    "artist": item["track"]["artists"][0]["name"].stringValue,
                                    "album_uri": item["track"]["album"]["images"][0]["url"].stringValue,
                                    "spotify_uri": item["track"]["uri"].stringValue,
                                    "preview_uri": preview_uri
                                    ]
                                )
                                
                                self.pagedSongs.append(song!)
                            }
                            
                            guard let nextQueryUrl = json["next"].string else {
                                fulfill(self.pagedSongs)
                                return
                            }
                            
                            self.fetchPlaylistSongsHelper(query: nextQueryUrl, headers: headers)
                                .then { results in
                                    fulfill(results)
                                }.catch { error in
                                    reject(error)
                                }
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func fetchUserPlaylists(spotifyToken: String) -> Promise<[SpotifyPlaylist]> {
        let searchURL = "https://api.spotify.com/v1/me/playlists"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(spotifyToken)"]
        
        return Promise { fulfill, reject in
            sessionManager.request(searchURL, headers: headers)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        
                        if let items = json["items"].array {
                            var playlists: [SpotifyPlaylist] = []
                            for item in items {
                                var image_uri = ""
                                
                                if let imgArr = item["images"].array {
                                    if imgArr.count > 0 {
                                        image_uri = imgArr[0]["url"].stringValue
                                    }
                                }
                                
                                let playlist = SpotifyPlaylist(data: [
                                    "playlist_id": item["id"].stringValue,
                                    "name": item["name"].stringValue,
                                    "image_uri": image_uri,
                                    "song_count": item["tracks"]["total"].intValue
                                    ]
                                )
                                
                                playlists.append(playlist!)
                            }
                            fulfill(playlists)
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }

    
    

    
    func requestErrorHandler(response: DataResponse<Data>) {
        print("Success: \(response.result.isSuccess)")
        print("Response String: \(String(describing: response.result.value))")
        
        if let error = response.result.error as? AFError {
            switch error {
            case .invalidURL(let url):
                print("Invalid URL: \(url) - \(error.localizedDescription)")
            case .parameterEncodingFailed(let reason):
                print("Parameter encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .multipartEncodingFailed(let reason):
                print("Multipart encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .responseValidationFailed(let reason):
                print("Response validation failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    print("Downloaded file could not be read")
                case .missingContentType(let acceptableContentTypes):
                    print("Content Type Missing: \(acceptableContentTypes)")
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                case .unacceptableStatusCode(let code):
                    print("Response status code was unacceptable: \(code)")
                }
            case .responseSerializationFailed(let reason):
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            }
            
            print("Underlying error: \(String(describing: error.underlyingError))")
        } else if let error = response.result.error as? URLError {
            print("URLError occurred: \(error)")
        } else {
            print("Unknown error: \(String(describing: response.result.error))")
        }
    }
}
