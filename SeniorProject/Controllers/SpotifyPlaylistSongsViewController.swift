//
//  SpotifyPlaylistSongsViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/21/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//

import SpotifyLogin
import UIKit
import Alamofire
import AVFoundation
import PromiseKit
import ReSwift

class SpotifyPlaylistSongsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
    
    @IBOutlet var playlistTitleLabel: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var playlist: SpotifyPlaylist!
    var songs: [SpotifySong]!
    
    var searchQuery: String = ""
    var filteredSongs: [SpotifySong] {
        get {
            return songs.filter { return searchQuery == "" ||
                                         $0.title.contains(searchQuery) ||
                                         $0.artist.contains(searchQuery)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        playlistTitleLabel.title = playlist.name
        mainStore.subscribe(self)
        fetchSpotifySongsInPlaylist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        songs = []
    }
    
    func newState(state: AppState) {
        songs = state.spotifyPlaylistSongs
        tableView.reloadData()
    }
    
    /* When you use the search bar */
    func fetchSpotifySongsInPlaylist() {
        showLoadingAlert(uiView: self.view)
        
        Api.shared.getSpotifyAccessToken()
            .then { (token) -> Promise<[SpotifySong]> in
                SpotifyApi.shared.fetchPlaylistSongs(playlistID: self.playlist.playlistID, spotifyToken: token)
            }.then { (songs) -> Void in
                mainStore.dispatch(FetchedSpotifyPlaylistSongsAction(spotifyPlaylistSongs: songs))
                self.dismissLoadingAlert(uiView: self.view)
            }.catch { (error) in
                self.dismissLoadingAlert(uiView: self.view)
                print(error)
        }
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongs.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = filteredSongs[indexPath.row]
        let url = URL(string: song.imageURI)
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotifyPlaylistSongCell", for: indexPath) as! SpotifyPlaylistSongCell
       
        
        cell.selectionStyle = .none
        cell.songTitleLabel.text = song.title
        cell.songArtistLabel.text = song.artist
        
        if let image = song.image {
            cell.songUIImage.image = image
        } else {
            cell.songUIImage.kf.indicatorType = .activity
            cell.songUIImage.kf.setImage(with: url, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image == nil) {
                    cell.songUIImage.image = UIImage(named: "default-album-cover")
                } else {
                    song.image = image
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.addSongToQueue(song: self.songs[indexPath.row])
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let addToQueueAction = UIContextualAction(style: .normal, title: "QueueIt!") { (action, view, handler) in
            let song = self.songs[indexPath.row]
            
            firstly {
                Api.shared.queueSong(queueId: (mainStore.state.selectedQueue?.id)!, song: song)
                }.then { (result) -> Void in
                    
                }.catch { (error) in
                    print(error)
                    self.showErrorAlert(error: error)
            }
        }
        
        addToQueueAction.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6980392157, blue: 0.9764705882, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [addToQueueAction])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    // MARK: Keyboard Delegate Functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            searchQuery = text
            tableView.reloadData()
        }
        
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchQuery = ""
        tableView.reloadData()
        view.endEditing(true)
    }
    
    /* When user clicks on a song, give user the option to add the song onto the current queue */
    func addSongToQueue(song: SpotifySong) {
        let alertController = UIAlertController(title: "Add song to queue", message: "Add \(song.title) to queue?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let actionOk = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
            firstly {
                Api.shared.queueSong(queueId: (mainStore.state.selectedQueue?.id)!, song: song)
                }.then { (result) -> Void in
                    
                }.catch { (error) in
                    print(error)
                    self.showErrorAlert(error: error)
            }
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func goBackToSelectedQueue(_ sender: Any) {
        performSegue(withIdentifier: "unwindSequeToSelectedPlaylist", sender: self)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

