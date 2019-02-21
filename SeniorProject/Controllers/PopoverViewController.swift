//
//  PopoverViewController.swift
//  
//
//  Created by Patrick Cook on 4/25/18.
//

import UIKit
import DynamicBlurView

class PopoverViewController: UIViewController {
    var delegate: JoinedQueuesViewController!
    var queueName: String!
    
    @IBOutlet weak var cancelButton: UIButton!
 
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate.popoverDismissed()
        }
    }
    
    @IBAction func createQueueTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Queue Name", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Awesome queue name"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        }
        
        let saveAction = UIAlertAction(title: "Next", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let queueNameTextField = alertController.textFields![0] as UITextField
            self.queueName = queueNameTextField.text!
            self.performSegue(withIdentifier: "show_create_queue", sender: self)
        })
        saveAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func joinQueueTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "show_join_queue", sender: self)
    }
    
    @objc func alertTextFieldDidChange(field: UITextField){
        let alertController:UIAlertController = self.presentedViewController as! UIAlertController;
        let textField :UITextField  = alertController.textFields![0];
        let addAction: UIAlertAction = alertController.actions[1];
        addAction.isEnabled = (textField.text?.count)! >= 5;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_create_queue" {
            let controller = segue.destination as! CreateQueueViewController
            controller.queueName = self.queueName
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
