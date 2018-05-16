//
//  MusicPlayerViewController.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/15/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    
    @IBAction func playbackToggleTapped(_ sender: Any) {
        print("playback toggled")
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        print("next song")
    }
    
    @IBAction func closeMusicPlayerSwiped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeMusicPlayerTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
