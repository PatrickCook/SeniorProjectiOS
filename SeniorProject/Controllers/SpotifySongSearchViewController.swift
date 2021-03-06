//
//  SongSearchViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/1/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import SpotifyLogin
import UIKit
import Alamofire
import AVFoundation
import PromiseKit
import ReSwift

class SpotifySongSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var queueToAddTo: Queue!
    var searchResults: [SpotifySong] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainStore.subscribe(self)
        searchBar.delegate = self
    }
    
    func newState(state: AppState) {
        searchResults = state.spotifySearchResults
        tableView.reloadData()
    }
    
    /* When you use the search bar */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        showLoadingAlert(uiView: self.view)

        Api.shared.getSpotifyAccessToken()
            .then { (token) -> Promise<[SpotifySong]> in
                SpotifyApi.shared.search(query: searchBar.text!, spotifyToken: token)
            }.then { (songs) -> Void in
                mainStore.dispatch(FetchedSpotifySearchResultsAction(spotifySearchResults: songs))
                self.dismissLoadingAlert(uiView: self.view)
            }.catch { (error) in
                self.dismissLoadingAlert(uiView: self.view)
                print(error)
            }
        self.searchBar.endEditing(true)
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SpotifySearchSongCell
        let song = searchResults[indexPath.row]
        let url = URL(string: song.imageURI)
        
        cell.selectionStyle = .none
        cell.songTitleLabel.text = song.title
        cell.songArtistLabel.text = song.artist
        cell.setSongForCell(spotifySong: song)
        
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
            self.addSongToQueue(song: self.searchResults[indexPath.row])
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
                self.showErrorAlert(error: error.localizedDescription)
            }
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (self.isMovingFromParent) {
            MusicPlayer.shared.stopPreviewURL()
        }
    }

}
