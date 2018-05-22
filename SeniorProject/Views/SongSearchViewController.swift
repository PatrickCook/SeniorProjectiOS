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
            //print("HELLO")
            
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String : AnyObject]
            
            //print(readableJSON)
            
            if let tracks = readableJSON["tracks"] as? [String: AnyObject]{
                if let items = tracks["items"] as? [[String: AnyObject]]{
                    
                    for i in 0..<items.count{
                        var artistName = String()
                        let item = items[i]
                        let title = item["name"] as! String
                        let previewURL = item["preview_url"] as! String
                        let songURL = item["uri"] as! String
                        //print(previewURL)
                        
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
        return listofSearch.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SongSearchCell
        let mainImageURL = URL(string: listofSearch[indexPath.row].image)
        let mainImageData = NSData(contentsOf: mainImageURL!)
        let mainImage = UIImage(data: mainImageData! as Data)
        
        cell.songPreviewLabel.tag = indexPath.row
        cell.songImageLabel.image = mainImage
        cell.songTitleLabel.text = listofSearch[indexPath.row].title
        cell.songArtistLabel.text = listofSearch[indexPath.row].artist
        
        return cell
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        //print("Sender Tag: \(sender)")
        if (num != sender.tag){
            num = sender.tag
            flag = 0
        }
        if (flag == 0){
            let preview = listofSearch[sender.tag].previewURL
            //print("SONG PREVIEW: \(preview)")
            self.downloadSong(url: URL(string: preview)!)
        }
        else if (flag == 1){
            sound.pause()
            flag = 0;
        }
    }
    func downloadSong(url: URL)
    {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            self.play(url: customURL!)
        })
        downloadTask.resume()
    }
    
    func play(url: URL)
    {
        do{
            sound = try AVAudioPlayer(contentsOf: url)
            sound.prepareToPlay()
            sound.play()
            flag = 1
        }
        catch{
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goBack"{
            print("BEEP BOOP UNWINDING SEGUE")
            //let now = NSDate()
            //let nowTime = String(now.timeIntervalSince1970)
            //listofSearch[((self.tableView .indexPathForSelectedRow)?.row)!].time = nowTime.replacingOccurrences(of: ".", with: "0")
            let dest = segue.destination as? QueueViewController
            
            dest?.addSong(newSong: listofSearch[((self.tableView .indexPathForSelectedRow)?.row)!])
        }
    }
}
