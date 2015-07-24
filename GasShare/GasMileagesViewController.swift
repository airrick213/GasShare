//
//  GasMileagesTableViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/24/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class GasMileagesViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let suggestedMileageValues = ["Compact Car: 26", "Large Car: 21", "Midsize Car: 25", "Minicompact Car: 24", "Minivan: 21", "Pickup Truck: 19", "Small Pickup: 20", "Small SUV: 23", "Subcompact Car: 24", "SUV: 18", "Two-Seater Car: 23", "Wagon: 26"]
    var selectedCell: GasMileageCell?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.titleTextAttributes = ["UITextAttributefont" : "Avenir"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension GasMileagesViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedMileageValues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GasMileageCell", forIndexPath: indexPath) as! GasMileageCell
        
        cell.gasMileageLabel.text = suggestedMileageValues[indexPath.row]
        cell.checkmark.hidden = true
        
        return cell
    }
    
}

extension GasMileagesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newCell = tableView.cellForRowAtIndexPath(indexPath) as! GasMileageCell
        
        newCell.gasMileageLabel.text = suggestedMileageValues[indexPath.row]
        
        if selectedCell != nil {
            if selectedCell != newCell{
                selectedCell!.selected = false
                selectedCell = newCell
            }
            else {
                newCell.selected = false
                selectedCell = nil
            }
        }
        else {
            selectedCell = newCell
        }
    }
    
}
