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
    var songs: [SpotifySong] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistTitleLabel.title = playlist.name
        mainStore.subscribe(self)
        fetchSpotifySongsInPlaylist()
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
                Api.shared.fetchSpotifyPlaylistSongs(playlistID: self.playlist.playlistID, spotifyToken: token)
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
        return songs.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
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
            print("Add Action Tapped")
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

