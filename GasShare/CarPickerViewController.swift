//
//  CarPickerViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/30/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import Alamofire
import Kanna

class CarPickerViewController: UIViewController {
    
    @IBOutlet weak var gasMileageLabel: UILabel!
    @IBOutlet weak var carPickerView: UIPickerView!
    
    var years: [String] = []
    var makes: [String] = []
    var models: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadYears()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadYears() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let requestString = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/year"
        
        Alamofire.request(.GET, requestString, parameters: nil).responseString { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if AlamofireHelper.requestSucceeded(response, error: error) {
                self.handleLoadYearsResponse(data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func handleLoadYearsResponse(data: AnyObject) {
        let xml = data as! String
        
        if let doc = Kanna.XML(xml: xml, encoding: NSUTF8StringEncoding) {
            var count = 0
            
            for node in doc.css("value") {
                years.append(node.text!)
            }
            
            carPickerView.reloadComponent(0)
        }
        else {
            UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

extension CarPickerViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        }
        else if component == 1 {
            return makes.count
        }
        else {
            return models.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var label = UILabel()
        
        if component == 0 {
            label.text = years[row]
        }
        else if component == 1 {
            label.text = makes[row]
        }
        else {
            label.text = models[row]
        }
        
        label.font = UIFont(name: "Avenir", size: 28)
        label.textColor = UIColor.whiteColor()
        
        return label
    }
    
}

extension CarPickerViewController: UIPickerViewDelegate {
    
    
    
}
