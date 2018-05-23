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
    let api: Api = Api.api
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchURL = String()
    var searchResults: [SpotifySong] = []
    var sound = AVAudioPlayer()
    /* DO I NEED THESE */
    var flag = 0
    var num = -1
    
    /* When you use the search bar */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.view.endEditing(true)
        showLoadingAlert(uiView: self.view)
        
        firstly {
            self.api.getSpotifyAccessToken()
        }.then { (token) -> Promise<[SpotifySong]> in
            self.api.searchSpotify(query: searchBar.text!, spotifyToken: token)
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
        let mainImageURL = URL(string: searchResults[indexPath.row].image)
        let mainImageData = NSData(contentsOf: mainImageURL!)
        let mainImage = UIImage(data: mainImageData! as Data)
        
        cell.songPreviewLabel.tag = indexPath.row
        cell.songImageLabel.image = mainImage
        cell.songTitleLabel.text = searchResults[indexPath.row].title
        cell.songArtistLabel.text = searchResults[indexPath.row].artist
        
        return cell
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        //print("Sender Tag: \(sender)")
        if (num != sender.tag){
            num = sender.tag
            flag = 0
        }
        if (flag == 0){
            let preview = searchResults[sender.tag].previewURL
            //print("SONG PREVIEW: \(preview)")
            self.downloadSong(url: URL(string: preview)!)
        }
        else if (flag == 1){
            sound.pause()
            flag = 0;
        }
    }
    func downloadSong(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            self.play(url: customURL!)
        })
        downloadTask.resume()
    }
    
    func play(url: URL) {
        do {
            sound = try AVAudioPlayer(contentsOf: url)
            sound.prepareToPlay()
            sound.play()
            flag = 1
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goBack"{
            print("BEEP BOOP UNWINDING SEGUE")
        }
    }
}
