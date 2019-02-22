//
//  SpotifyPlaylistViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/20/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//

import SpotifyLogin
import UIKit
import Alamofire
import AVFoundation
import PromiseKit
import ReSwift

class SpotifyPlaylistsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
    
    @IBOutlet weak var tableView: UITableView!
    
    var spotifyUserPlaylists: [SpotifyPlaylist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainStore.subscribe(self)
        fetchSpotifyUserPlaylists()
    }
    
    func newState(state: AppState) {
        spotifyUserPlaylists = state.spotifyUserPlaylists
        tableView.reloadData()
    }
    
    func fetchSpotifyUserPlaylists() {
        showLoadingAlert(uiView: self.view)
        
        Api.shared.getSpotifyAccessToken()
            .then { (token) -> Promise<[SpotifyPlaylist]> in
                Api.shared.fetchSpotifyUserPlaylists(spotifyToken: token)
            }.then { (playlists) -> Void in
                mainStore.dispatch(FetchedSpotifyUserPlaylistsAction(spotifyUserPlaylists: playlists))
                self.dismissLoadingAlert(uiView: self.view)
            }.catch { (error) in
                self.dismissLoadingAlert(uiView: self.view)
                print(error)
        }
    }
    
    
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotifyUserPlaylists.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotifyPlaylistCell", for: indexPath) as! SpotifyPlaylistCell
        
        cell.playlistNameLabel.text = spotifyUserPlaylists[indexPath.row].name
        cell.playlistUIImage.image = spotifyUserPlaylists[indexPath.row].playlistImage
        cell.playlistSongCountLabel.text = "\(spotifyUserPlaylists[indexPath.row].songCount) Songs"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: "show_playlist_songs", sender: self)
    }
    
    // MARK: Segue Handlers
    @IBAction func goBackToSelectedQueue(_ sender: Any) {
        performSegue(withIdentifier: "unwindSequeToSelectedQueue", sender: self)
    }
    
    @IBAction func unwindToSpotifyPlaylistsVC(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SpotifyPlaylistSongsViewController {
            if let playlistSongsVC = segue.destination as? SpotifyPlaylistSongsViewController {
                let queue = spotifyUserPlaylists[(tableView.indexPathForSelectedRow?.row)!]
                playlistSongsVC.playlist = queue
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
