//
//  DateFormatter.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/24/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class Utils {
    
    static let shared: Utils = Utils()
    
    func convertDateToEpoch(dateString: String) -> Double {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let datePublished = dateFormatter.date(from: dateString) {
            return datePublished.timeIntervalSince1970
        }
        return 0.0
    }
}
