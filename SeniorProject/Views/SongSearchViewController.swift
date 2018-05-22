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

class SongSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchURL = String()
    var listofSearch = [SongInfoCell]()
    var sound = AVAudioPlayer()
    /* DO I NEED THESE */
    var flag = 0
    var num = -1
    
    /* When you use the search bar */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print("HERE")
        listofSearch = [SongInfoCell]()
        let word = searchBar.text
        let modifiedWord = word?.replacingOccurrences(of: " ", with: "+")
        searchURL = "https://api.spotify.com/v1/search?q=\(modifiedWord!)&type=track"
        print(searchURL)
        parseWithAlamo(url: searchURL)
        self.view.endEditing(true)
    }
    
    func parseWithAlamo(url: String){
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                print(error.debugDescription)
            }
            print(token!)
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token!)"
            ]
            
            Alamofire.request(url, headers: headers).responseJSON(completionHandler: {
                response in
                self?.parseData(JSONData: response.data!)
            })
        }
        
    }
    
    func parseData(JSONData : Data){
        do{
            print("HELLO")
            
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String : AnyObject]
            
            print(readableJSON)
            
            if let tracks = readableJSON["tracks"] as? [String: AnyObject]{
                if let items = tracks["items"] as? [[String: AnyObject]]{
                    
                    for i in 0..<items.count{
                        var artistName = String()
                        let item = items[i]
                        let title = item["name"] as! String
                        let previewURL = item["preview_url"] as! String
                        let songURL = item["uri"] as! String
                        print(previewURL)
                        
                        if let album = item["album"] as? [String: AnyObject]{
                            if let artistInfo = album["artists"] as? [[String: AnyObject]]{
                                let detailedInfo = artistInfo[0]
                                artistName = detailedInfo["name"] as! String
                                
                            }
                            if let images = album["images"] as? [[String: AnyObject]]{
                                let imageData = images[0]
                                let imageString = (imageData["url"] as! String)
                                listofSearch.append(SongInfoCell(title: title, image: imageString, artist: artistName, songURL: songURL, previewURL: previewURL, time: "" ))
                                self.tableView.reloadData()
                            }
                        }
                        
                        
                    }
                }
            }
        }
        catch{
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
        return 5
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? SongSearchCell
        
        searchCell?.songTitleLabel.text = "DEFAULT TITLE NAME"
        searchCell?.songArtistLabel.text = "DEFAULT ARITST LABEL"
        
        return searchCell!
    }

}
