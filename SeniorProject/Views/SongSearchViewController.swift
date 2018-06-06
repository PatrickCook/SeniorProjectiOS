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

class SongSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
    
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
        self.view.endEditing(true)
        showLoadingAlert(uiView: self.view)
        
        firstly {
            Api.shared.getSpotifyAccessToken()
        }.then { (token) -> Promise<[SpotifySong]> in
            Api.shared.searchSpotify(query: searchBar.text!, spotifyToken: token)
        }.then { (songs) -> Void in
            mainStore.dispatch(FetchedSpotifySearchResultsAction(spotifySearchResults: songs))
            self.dismissLoadingAlert(uiView: self.view)
        }.catch { (error) in
            self.dismissLoadingAlert(uiView: self.view)
            print(error)
        }
    }
    
    /* TABLE DELEGATE METHODS */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SongSearchCell
        let mainImageURL = URL(string: searchResults[indexPath.row].imageURI)
        let mainImageData = NSData(contentsOf: mainImageURL!)
        let mainImage = UIImage(data: mainImageData! as Data)

        cell.selectionStyle = .none
        cell.songImageLabel.image = mainImage
        cell.songTitleLabel.text = searchResults[indexPath.row].title
        cell.songArtistLabel.text = searchResults[indexPath.row].artist
        cell.setSongForCell(spotifySong: searchResults[indexPath.row]) 
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addSongToQueue(song: searchResults[indexPath.row])
    }

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
    
    override func viewWillDisappear(_ animated: Bool) {
        if (self.isMovingFromParentViewController) {
            MusicPlayer.shared.stopPreviewURL()
        }
    }
}
