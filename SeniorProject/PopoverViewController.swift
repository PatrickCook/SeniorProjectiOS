//
//  PopoverViewController.swift
//  
//
//  Created by Patrick Cook on 4/25/18.
//

import UIKit
import DynamicBlurView

class PopoverViewController: UIViewController {
    var delegate: QueuesViewController!
    
    @IBOutlet weak var cancelButton: UIButton!
 
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate.popoverDismissed()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
    }
}
