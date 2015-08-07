//
//  VenmoViewController.swift
//  GasShare
//
//  Created by Eric Kim on 8/7/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import Venmo_iOS_SDK
import MBProgressHUD

class VenmoViewController: UIViewController {

    @IBOutlet weak var transactionTypeControl: UISegmentedControl!
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var paymentNoteTextField: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    
    var cost: Double!
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        if transactionTypeControl.selectedSegmentIndex == 0 {
            Venmo.sharedInstance().sendRequestTo(
                recipientTextField.text,
                amount: UInt(cost * 100),
                note: paymentNoteTextField.text,
                completionHandler: paymentHandler)
        }
        else if transactionTypeControl.selectedSegmentIndex == 1 {
            Venmo.sharedInstance().sendPaymentTo(
                recipientTextField.text,
                amount: UInt(cost * 100),
                note: paymentNoteTextField.text,
                completionHandler: paymentHandler)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        costLabel.text = NSString(format: "$%.2f", cost) as String
        
        recipientTextField.becomeFirstResponder()
        
        if Venmo.isVenmoAppInstalled() {
            Venmo.sharedInstance().defaultTransactionMethod = VENTransactionMethod.AppSwitch
        }
        else {
            Venmo.sharedInstance().defaultTransactionMethod = VENTransactionMethod.API
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func paymentHandler(transaction: VENTransaction!, success: Bool, error: NSError!) -> Void {
        if error != nil {
            UIAlertView(title: error.localizedDescription, message: error.localizedRecoverySuggestion, delegate: nil, cancelButtonTitle: "OK").show()
        }
        else {
            UIAlertView(title: "Congratulations!", message: "Your transaction is complete", delegate: nil, cancelButtonTitle: "OK").show()
        }
        
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
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

extension VenmoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
