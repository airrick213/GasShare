//
//  KannaHelper.swift
//  GasShare
//
//  Created by Eric Kim on 8/3/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import MBProgressHUD
import Kanna

class KannaHelper {
    
    static func ParseXMLFromData(data: AnyObject, view: UIView, docParser: (doc: XMLDocument) -> Void) {
        let xml = data as! String
        
        if let doc = Kanna.XML(xml: xml, encoding: NSUTF8StringEncoding) {
            docParser(doc: doc)
        }
        else {
            UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
    }
    
}
