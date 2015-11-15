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
    
    static func scrapeHTMLForURL(url: String, responseHandler: (data: AnyObject) -> Void, view: UIView) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        Alamofire.request(.GET, url, parameters: nil).responseString { (_, response, result) -> Void in
            if result.isSuccess {
                responseHandler(data: result.data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
            }
            
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
    }
    
};
