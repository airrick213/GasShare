//
//  CustomTableViewCell.swift
//  GasShare
//
//  Created by Eric Kim on 7/24/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class GasMileageCell: UITableViewCell {

    @IBOutlet weak var gasMileageLabel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        checkmark.hidden = !selected
    }
    
}
