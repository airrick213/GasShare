//
//  Alamofire Helper.swift
//  GasShare
//
//  Created by Eric Kim on 7/15/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import SwiftyJSON
import Alamofire
import MBProgressHUD
import UIKit

class AlamofireHelper {
    
    static func requestSucceeded(response: NSURLResponse!, error: NSError!) -> Bool {
        if let httpResponse = response as? NSHTTPURLResponse {
            return error == nil && httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
        }
        
        return false
    }
    
    static func scrapeHTMLForURL(url: String, responseHandler: (data: AnyObject) -> Void, view: UIView) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        Alamofire.request(.GET, url, parameters: nil).responseString { (_, response, data, error) -> Void in
            if self.requestSucceeded(response, error: error) {
                responseHandler(data: data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
            }
            
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
    }
    
};
