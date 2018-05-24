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

class SongSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var queueToAddTo: Queue!
    var searchResults: [SpotifySong] = []
    
    
    /* When you use the search bar */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.view.endEditing(true)
        showLoadingAlert(uiView: self.view)
        
        firstly {
           Api.shared.getSpotifyAccessToken()
        }.then { (token) -> Promise<[SpotifySong]> in
            Api.shared.searchSpotify(query: searchBar.text!, spotifyToken: token)
        }.then { (songs) -> Void in
            self.searchResults = songs
            self.tableView.reloadData()
            self.dismissLoadingAlert(uiView: self.view)
        }.catch { (error) in
            self.dismissLoadingAlert(uiView: self.view)
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                Api.shared.queueSong(queueId: 1, song: song)
            }.then { (result) -> Void in
                //self.performSegue(withIdentifier: "goBack", sender: self)
            }.catch { (error) in
                print(error)
            }
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goBack"{
            print("BEEP BOOP UNWINDING SEGUE")
            //MusicPlayer.shared.stopPreviewURL()
        }
    }
}
