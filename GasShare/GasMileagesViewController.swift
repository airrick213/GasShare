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
    @IBOutlet weak var tableView: UITableView!
    
    let suggestedMileageValues = ["Compact Car: 26", "Large Car: 21", "Midsize Car: 25", "Minicompact Car: 24", "Minivan: 21", "Pickup Truck: 19", "Small Pickup: 20", "Small SUV: 23", "Subcompact Car: 24", "SUV: 18", "Two-Seater Car: 23", "Wagon: 26"]
    var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.titleTextAttributes = ["UITextAttributeFont" : "Avenir"]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = selectedIndex {
            let indexPath = NSIndexPath(forRow: selectedIndex, inSection: 0)
            
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
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
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GasMileageCell
        
        if selectedIndex != nil {
            if selectedIndex != indexPath.row {
                let previousIndexPath = NSIndexPath(forRow: selectedIndex!, inSection: 0)
                let previousCell = tableView.cellForRowAtIndexPath(previousIndexPath) as! GasMileageCell
                
                previousCell.selected = false
                selectedIndex = indexPath.row
            }
            else {
                cell.selected = false
                selectedIndex = nil
            }
        }
        else {
            selectedIndex = indexPath.row
        }
    }
    
}
