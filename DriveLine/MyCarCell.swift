//
//  MyCarCell.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/28/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class MyCarCell: UITableViewCell {

    @IBOutlet var lblYear: UILabel!
    @IBOutlet var lblMake: UILabel!
    @IBOutlet var lblModel: UILabel!
    @IBOutlet weak var carImageView: UIImageView! {
        didSet {
            carImageView.layer.cornerRadius = 10
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
