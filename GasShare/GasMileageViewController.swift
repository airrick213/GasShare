//
//  GasMileageViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/6/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class GasMileageViewController: UIViewController {

    @IBOutlet weak var gasMileageTextField: UITextField!
    @IBOutlet weak var gasMileagePickerView: UIPickerView!
    let suggestedMileageValues = ["Don't Use Suggestions", "Compact Car: 26", "Large Car: 21", "Midsize Car: 25", "Minicompact Car: 24", "Minivan: 21", "Pickup Truck: 19", "Small Pickup: 20", "Small SUV: 23", "Subcompact Car: 24", "SUV: 18", "Two-Seater Car: 23", "Wagon: 26"]
    var selectedSuggestedMileageValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gasMileagePickerView.dataSource = self
        gasMileagePickerView.delegate = self
        
        //this dismisses the keyboard after tapping outside of it
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "GasMileageDone" {
            if gasMileageTextField.text.isEmpty && selectedSuggestedMileageValue == 0 {
                let alert = UIAlertView()
                alert.title = "No Gas Mileage"
                alert.message = "Please enter your car's gas mileage or choose one from the suggestions list"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
            else {
                return true
            }
        }
        
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gasPriceViewController = segue.destinationViewController as! GasPriceViewController
        
        if selectedSuggestedMileageValue == 0 {
            gasPriceViewController.gasMileage = gasMileageTextField.text.toInt()
        }
        else {
            let suggestedMileageValueString = suggestedMileageValues[selectedSuggestedMileageValue]
            let gasMileage = suggestedMileageValueString.substringFromIndex(advance(suggestedMileageValueString.startIndex, count(suggestedMileageValueString) - 2)).toInt()
            gasPriceViewController.gasMileage = gasMileage
        }
    }

}

extension GasMileageViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Int(suggestedMileageValues.count)
    }
    
}

extension GasMileageViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return suggestedMileageValues[advance(0, row)]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSuggestedMileageValue = row
        gasMileageTextField.enabled = (selectedSuggestedMileageValue == 0)
    }
    
}
