//
//  DateFormatter.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/24/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class ConversionUtilities {
    
    static let shared: ConversionUtilities = ConversionUtilities()
    
    private init () {}
    
    func convertDateToEpoch(dateString: String) -> Double {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let datePublished = dateFormatter.date(from: dateString) {
            return datePublished.timeIntervalSince1970
        }
        return 0.0
    }
    
    func convertTimeInSecondsToString(seconds: Double) -> String {
        let intSeconds = Int(seconds)
        let minutes = intSeconds / 60
        let seconds = intSeconds % 60
        var timestamp = "\(minutes):"
        
        timestamp.append(seconds < 10 ? "0\(seconds)" : "\(seconds)")
        
        return timestamp
    }
}
