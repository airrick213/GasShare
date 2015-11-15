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
    var recipients: [String]!
    var recipientCount = 0
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        recipients = recipientTextField.text!.componentsSeparatedByString(",")
        for x in 0 ..< recipients.count {
            recipients[x] = NSString(string: recipients[x]).stringByReplacingOccurrencesOfString(" ", withString: "")
        }
        
        if transactionTypeControl.selectedSegmentIndex == 0 {
            for recipient in recipients! {
                Venmo.sharedInstance().sendRequestTo(
                    recipient,
                    amount: UInt(cost * 100),
                    note: paymentNoteTextField.text,
                    completionHandler: paymentHandler)
            }
        }
        else if transactionTypeControl.selectedSegmentIndex == 1 {
            for recipient in recipients! {
                Venmo.sharedInstance().sendPaymentTo(
                    recipient,
                    amount: UInt(cost * 100),
                    note: paymentNoteTextField.text,
                    completionHandler: paymentHandler)
            }
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
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func paymentHandler(transaction: VENTransaction!, success: Bool, error: NSError!) -> Void {
        if error != nil {
            UIAlertView(title: error.localizedDescription, message: error.localizedRecoverySuggestion, delegate: nil, cancelButtonTitle: "OK").show()
        }
        else {
            let recipientString = recipients[recipientCount]
            
            UIAlertView(title: "Congratulations!", message: "Your transaction with \(recipientString) is complete", delegate: nil, cancelButtonTitle: "OK").show()
            
            recipientCount++
            
            self.performSegueWithIdentifier("VenmoBack", sender: self)
        }
        
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }

}

extension VenmoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === recipientTextField {
            paymentNoteTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
