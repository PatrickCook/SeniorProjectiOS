//
//  UIViewControllerExtensions.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/10/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//
import UIKit
import Foundation

extension UIViewController {
    func showLoadingAlert() {
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: alert.view.bounds)
        loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func dismissLoadingAlert() {
        dismiss(animated: false, completion: nil)
    }
}
