//
//  Alamofire Helper.swift
//  GasShare
//
//  Created by Eric Kim on 7/15/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import SwiftyJSON

class AlamofireHelper {
    
    static func requestSucceeded(response: NSURLResponse!, error: NSError!) -> Bool {
        if let httpResponse = response as? NSHTTPURLResponse {
            return error == nil && httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
        }
        
        return false
    }
    
}
