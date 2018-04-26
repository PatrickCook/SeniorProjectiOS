//
//  PopoverViewController.swift
//  
//
//  Created by Patrick Cook on 4/25/18.
//

import UIKit

class PopoverViewController: UIViewController {
    
    
    @IBOutlet weak var cancelButton: UIButton!
 
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        let blurredBackgroundView = UIVisualEffectView()
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.sendSubview(toBack: blurredBackgroundView)
    }
}
